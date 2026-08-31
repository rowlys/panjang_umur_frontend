import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';
import '../widgets/reward_card.dart';

class MyStoreScreen extends ConsumerStatefulWidget {
  const MyStoreScreen({super.key});

  @override
  ConsumerState<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends ConsumerState<MyStoreScreen> {
  String? _cancelingRewardId;

  Future<void> _handleCancel(String rewardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel reward?'),
        content: const Text('This sets stock to 0 so the reward is no longer available for friends to redeem. You can restock it later from its detail page.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Back')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Cancel reward')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelingRewardId = rewardId);
    final result = await ref.read(myShopControllerProvider.notifier).updateStock(rewardId, 0);
    if (!mounted) return;
    setState(() => _cancelingRewardId = null);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reward cancelled.')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Widget _buildList(List<Reward> rewards, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: () => ref.read(myShopControllerProvider.notifier).getMyShop(),
      child: rewards.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text(emptyMessage)),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                final canCancel = reward.isAvailable && reward.stock > 0;
                return RewardCard(
                  reward: reward,
                  onTap: () => context.push('/rewards/${reward.id}'),
                  actionLabel: canCancel ? 'Cancel' : null,
                  actionIcon: Icons.cancel_outlined,
                  actionInProgress: _cancelingRewardId == reward.id,
                  onAction: canCancel ? () => _handleCancel(reward.id) : null,
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myShopControllerProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Store'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'Unavailable'),
            ],
          ),
        ),
        body: state.when(
          data: (rewards) {
            final available = rewards.where((r) => r.isAvailable).toList();
            final unavailable = rewards.where((r) => !r.isAvailable).toList();

            return TabBarView(
              children: [
                _buildList(available, "You don't have any available rewards."),
                _buildList(unavailable, 'No unavailable rewards.'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => RefreshIndicator(
            onRefresh: () => ref.read(myShopControllerProvider.notifier).getMyShop(),
            child: ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text('Failed to load your store:\n$error')),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/rewards/new'),
          icon: const Icon(Icons.add),
          label: const Text('New Reward'),
        ),
      ),
    );
  }
}
