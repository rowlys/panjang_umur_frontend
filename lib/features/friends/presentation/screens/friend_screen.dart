import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';
import 'package:panjang_umur_frontend/features/chat/presentation/providers/chat_providers.dart';
import 'package:panjang_umur_frontend/features/chat/domain/models/conversation_summary.dart';
import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';

import '../widgets/friend_requests_sheet.dart';

class FriendScreen extends ConsumerWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendControllerProvider);
    final requestsState = ref.watch(friendRequestControllerProvider);
    final summaries = ref.watch(conversationSummariesControllerProvider).valueOrNull;
    final myUserId = ref.watch(authControllerProvider).valueOrNull?.id;
    final summaryByFriendId = {
      for (final summary in summaries ?? <ConversationSummary>[])
        summary.friendId: summary,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: requestsState.maybeWhen(
              data: (requestsTuple) {
                final incomingCount = requestsTuple.$1.length;
                if (incomingCount > 0) {
                  return Badge(
                    label: Text('$incomingCount'),
                    child: const Icon(Icons.inbox),
                  );
                }
                return const Icon(Icons.inbox);
              },
              orElse: () => const Icon(Icons.inbox),
            ),
            tooltip: 'Friend Requests',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => const FriendRequestSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Friend',
            onPressed: () {
              context.push('/user-search');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(friendControllerProvider.notifier).getFriends();
          await ref.read(friendRequestControllerProvider.notifier).getFriendRequests();
          await ref.read(conversationSummariesControllerProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            friendsState.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No friends to show.'),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final friend = friends[index];
                      final summary = summaryByFriendId[friend.id];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: GestureDetector(
                          onTap: () {
                            context.push('/foreign-profile/${friend.id}');
                          },
                          child: Badge(
                            isLabelVisible: (summary?.unreadCount ?? 0) > 0,
                            label: Text('${summary?.unreadCount}'),
                            child: CircleAvatar(
                              child: Text(friend.name.substring(0, 1).toUpperCase()),
                            ),
                          ),
                        ),
                        title: Text(friend.name),
                        subtitle: summary == null
                            ? null
                            : Text(
                                summary.lastMessage.senderId == myUserId
                                    ? 'You: ${summary.lastMessage.body}'
                                    : summary.lastMessage.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        onTap: () {
                          context.push('/chat/${friend.id}');
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.storefront),
                          tooltip: 'Visit Shop',
                          onPressed: () {
                            context.push('/shop/${friend.id}');
                          },
                        ),
                      );
                    },
                    childCount: friends.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Failed to load friends:\n$error')),
              ),
            ),
          ]
        ),
      ),
    );
  }

}