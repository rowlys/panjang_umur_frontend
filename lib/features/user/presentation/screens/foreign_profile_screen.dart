import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/presentation/providers/user_providers.dart';
import '../../../friends/presentation/providers/friend_providers.dart';

class ForeignProfileScreen extends ConsumerWidget {
  final String id;

  const ForeignProfileScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileControllerProvider(id));
    final friendState = ref.watch(friendControllerProvider);

    final bool isFriend = friendState.maybeWhen(
      data: (friends) => friends.any((friend) => friend.id == id),
      orElse: () => false,
    );

    final friendRequestState = ref.watch(friendRequestControllerProvider);

    final bool requestReceived = friendRequestState.maybeWhen(
      data: (requestsTuple) {
        final incomingRequests = requestsTuple.$1;
        return incomingRequests.any((request) => request.requester.id == id);
      },
      orElse: () => false,
    );

    final bool requestSent = friendRequestState.maybeWhen(
      data: (requestsTuple) {
        final outgoingRequests = requestsTuple.$2;
        return outgoingRequests.any((request) => request.addressee.id == id);
      },
      orElse: () => false,
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      
      body: userState.when(
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isFriend) ...[
                      if (requestReceived)
                        FilledButton.icon(
                          onPressed: () {
                            ref.read(friendRequestControllerProvider.notifier).acceptFriendRequest(id);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Accept Request'),
                        )
                      else if (requestSent)
                        OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.pending_rounded),
                          label: const Text('Request Sent'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: () {
                            ref.read(friendRequestControllerProvider.notifier).sendFriendRequest(id);
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Friend'),
                        ),
                      const SizedBox(width: 16),
                    ],
                    if (isFriend)
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement navigation to foreign user's shop via go_router
                        },
                        icon: const Icon(Icons.storefront),
                        label: const Text('Visit Shop'),
                      ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading profile: $error')),
      ),
    );
  }
}