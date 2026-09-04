import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';

class FriendRequestSheet extends ConsumerWidget {
  const FriendRequestSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsState = ref.watch(friendRequestControllerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Friend Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: requestsState.when(
                data: (requestsTuple) {
                  final incomingRequests = requestsTuple.$1;

                  if (incomingRequests.isEmpty) {
                    return const Center(child: Text('No pending requests.'));
                  }

                  return ListView.builder(
                    controller: scrollController, 
                    itemCount: incomingRequests.length,
                    itemBuilder: (context, index) {
                      final request = incomingRequests[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(request.requester.username),
                        subtitle: const Text('wants to be your friend'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                await ref.read(friendRequestControllerProvider.notifier).acceptFriendRequest(request.id);
                                ref.read(friendControllerProvider.notifier).getFriends();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                ref.read(friendRequestControllerProvider.notifier).declineFriendRequest(request.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        );
      },
    );
  }
}