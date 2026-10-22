import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/user/presentation/providers/user_providers.dart';

import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';
import '../widgets/balance_badge.dart';
import '../widgets/reward_shelf.dart';
import '../widgets/shop_stand.dart';

class FriendShopScreen extends ConsumerStatefulWidget {
  final String giverId;

  const FriendShopScreen({super.key, required this.giverId});

  @override
  ConsumerState<FriendShopScreen> createState() => _FriendShopScreenState();
}

class _FriendShopScreenState extends ConsumerState<FriendShopScreen> {
  Future<void> _handleRedeem(Reward reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem reward?'),
        content: Text('Redeem "${reward.title}" for ${reward.cost} points?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Redeem')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref.read(friendShopControllerProvider(widget.giverId).notifier).redeem(reward.id);
    if (!mounted) return;

    switch (result) {
      case Success():
        ref.invalidate(balancesProvider);
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _handleRedeem(reward);
                    },
                    icon: const Icon(Icons.redeem),
                    label: const Text('Redeem'),
                  ),
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
    final giverAsync = ref.watch(userProfileControllerProvider(widget.giverId));

    final title = giverAsync.maybeWhen(
      data: (user) => "${user.username}'s Shop",
      orElse: () => 'Shop',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'My claims',
            onPressed: () => context.push('/shop/${widget.giverId}/claims'),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: BalanceBadge(giverId: widget.giverId)),
          ),
        ],
      ),
      body: ShopStand(
        shopkeeper: giverAsync.valueOrNull?.gender,
        child: _Shelf(giverId: widget.giverId, onShowDetails: _showRewardDetails),
      ),
    );
  }
}

class _Shelf extends ConsumerWidget {
  final String giverId;
  final ValueChanged<Reward> onShowDetails;

  const _Shelf({required this.giverId, required this.onShowDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendShopControllerProvider(giverId));

    return RefreshIndicator(
      onRefresh: () => ref.read(friendShopControllerProvider(giverId).notifier).getShop(),
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

          return RewardShelf(rewards: rewards, onTap: onShowDetails);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text('Failed to load shop:\n$error')),
          ],
        ),
      ),
    );
  }
}
