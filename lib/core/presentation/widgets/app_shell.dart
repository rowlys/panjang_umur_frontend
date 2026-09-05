import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/challenge/presentation/providers/challenge_providers.dart';
import '../../../features/chat/presentation/providers/chat_providers.dart';
import '../../../features/friends/presentation/providers/friend_providers.dart';
import '../../../features/rewards/presentation/providers/reward_providers.dart';
import '../../../features/transactions/presentation/providers/transaction_providers.dart';

const _challengesBranchIndex = 0;
const _myStoreBranchIndex = 1;
const _friendsBranchIndex = 2;
const _historyBranchIndex = 3;

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onItemTapped(WidgetRef ref, int index) {
    switch (index) {
      case _challengesBranchIndex:
        ref.read(assignedChallengeControllerProvider.notifier).getAssignedToMe();
        ref.read(createdChallengeControllerProvider.notifier).getCreatedByMe();
      case _myStoreBranchIndex:
        ref.read(myShopControllerProvider.notifier).getMyShop();
      case _friendsBranchIndex:
        ref.read(friendControllerProvider.notifier).getFriends();
        ref.read(friendRequestControllerProvider.notifier).getFriendRequests();
        ref.read(conversationSummariesControllerProvider.notifier).refresh();
      case _historyBranchIndex:
        ref.read(transactionHistoryControllerProvider.notifier).loadHistory();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onItemTapped(ref, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Challenges',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'My Store',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}