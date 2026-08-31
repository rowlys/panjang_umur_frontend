import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/user/presentation/providers/user_providers.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';
import '../widgets/reward_card.dart';

class FriendShopScreen extends ConsumerStatefulWidget {
  final String giverId;

  const FriendShopScreen({super.key, required this.giverId});

  @override
  ConsumerState<FriendShopScreen> createState() => _FriendShopScreenState();
}

class _FriendShopScreenState extends ConsumerState<FriendShopScreen> {
  String? _redeemingRewardId;

  Future<void> _handleRedeem(String rewardId, String title, int cost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem reward?'),
        content: Text('Redeem "$title" for $cost points?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Redeem')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _redeemingRewardId = rewardId);
    final result = await ref.read(friendShopControllerProvider(widget.giverId).notifier).redeem(rewardId);
    if (!mounted) return;
    setState(() => _redeemingRewardId = null);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reward redeemed!')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  void _showRewardDetails(Reward reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (reward.description.isNotEmpty) ...[
                  Text(reward.description),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${reward.cost} pts')),
                    Chip(
                      label: Text(reward.visibility == RewardVisibility.restricted ? 'Restricted' : 'Public'),
                    ),
                    Chip(label: Text('Stock: ${reward.stock}')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendShopControllerProvider(widget.giverId));
    final giverAsync = ref.watch(userProfileControllerProvider(widget.giverId));

    final title = giverAsync.maybeWhen(
      data: (user) => "${user.username}'s Shop",
      orElse: () => 'Shop',
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(friendShopControllerProvider(widget.giverId).notifier).getShop(),
        child: state.when(
          data: (rewards) {
            if (rewards.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No rewards available right now.')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return RewardCard(
                  reward: reward,
                  onTap: () => _showRewardDetails(reward),
                  actionLabel: 'Redeem',
                  actionIcon: Icons.redeem,
                  actionInProgress: _redeemingRewardId == reward.id,
                  onAction: () => _handleRedeem(reward.id, reward.title, reward.cost),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text('Failed to load shop:\n$error')),
            ],
          ),
        ),
      ),
    );
  }
}
