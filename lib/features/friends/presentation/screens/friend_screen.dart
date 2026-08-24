import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';

import '../widgets/friend_requests_sheet.dart';

class FriendScreen extends ConsumerWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendControllerProvider);
    final requestsState = ref.watch(friendRequestControllerProvider);

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
              // TODO: Implementation for adding a friend
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(friendControllerProvider.notifier).getFriends();
          await ref.read(friendRequestControllerProvider.notifier).getFriendRequests();
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
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: GestureDetector(
                          onTap: () {
                            context.push('/foreign-profile/${friend.id}');
                          },
                          child: CircleAvatar(
                            child: Text(friend.name.substring(0, 1).toUpperCase()), 
                          ),
                        ),
                        title: Text(friend.name),
                        onTap: () {
                          // TODO: Navigate to friend chat room
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.storefront),
                          tooltip: 'Visit Shop',
                          onPressed: () {
                            // TODO: Navigate to friend's shop
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