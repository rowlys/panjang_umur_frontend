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
        ref.read(rewardClaimsRedeemedControllerProvider(widget.giverId).notifier).loadClaims();
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
    final giverAsync = ref.watch(userProfileControllerProvider(widget.giverId));

    final title = giverAsync.maybeWhen(
      data: (user) => "${user.username}'s Shop",
      orElse: () => 'Shop',
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Shop'),
              Tab(text: 'My Claims'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ShopTab(
              giverId: widget.giverId,
              redeemingRewardId: _redeemingRewardId,
              onShowDetails: _showRewardDetails,
              onRedeem: _handleRedeem,
            ),
            _ClaimsTab(giverId: widget.giverId),
          ],
        ),
      ),
    );
  }
}

class _ShopTab extends ConsumerWidget {
  final String giverId;
  final String? redeemingRewardId;
  final void Function(Reward reward) onShowDetails;
  final Future<void> Function(String rewardId, String title, int cost) onRedeem;

  const _ShopTab({
    required this.giverId,
    required this.redeemingRewardId,
    required this.onShowDetails,
    required this.onRedeem,
  });

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

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return RewardCard(
                reward: reward,
                onTap: () => onShowDetails(reward),
                actionLabel: 'Redeem',
                actionIcon: Icons.redeem,
                actionInProgress: redeemingRewardId == reward.id,
                onAction: () => onRedeem(reward.id, reward.title, reward.cost),
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
    );
  }
}

class _ClaimsTab extends ConsumerWidget {
  final String giverId;

  const _ClaimsTab({required this.giverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsState = ref.watch(rewardClaimsRedeemedControllerProvider(giverId));

    return RefreshIndicator(
      onRefresh: () => ref.read(rewardClaimsRedeemedControllerProvider(giverId).notifier).loadClaims(),
      child: claimsState.when(
        data: (page) {
          if (page.claims.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text("You haven't claimed anything from this shop yet.")),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: page.claims.length + (page.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= page.claims.length) {
                return Center(
                  child: page.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton(
                          onPressed: () =>
                              ref.read(rewardClaimsRedeemedControllerProvider(giverId).notifier).loadMore(),
                          child: const Text('Load more'),
                        ),
                );
              }
              return _MyClaimTile(giverId: giverId, claim: page.claims[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text('Failed to load claims:\n$error')),
          ],
        ),
      ),
    );
  }
}

class _MyClaimTile extends ConsumerStatefulWidget {
  final String giverId;
  final RewardClaim claim;

  const _MyClaimTile({required this.giverId, required this.claim});

  @override
  ConsumerState<_MyClaimTile> createState() => _MyClaimTileState();
}

class _MyClaimTileState extends ConsumerState<_MyClaimTile> {
  bool _isActing = false;

  String get _statusLabel {
    switch (widget.claim.status) {
      case ClaimStatus.pending:
        return 'Pending';
      case ClaimStatus.fulfilled:
        return 'Fulfilled';
      case ClaimStatus.refundRequested:
        return 'Refund Requested';
      case ClaimStatus.refunded:
        return 'Refunded';
    }
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (widget.claim.status) {
      case ClaimStatus.pending:
        return scheme.primary;
      case ClaimStatus.fulfilled:
        return Colors.green;
      case ClaimStatus.refundRequested:
        return Colors.orange;
      case ClaimStatus.refunded:
        return scheme.error;
    }
  }

  Future<void> _handleFulfill() async {
    setState(() => _isActing = true);
    final result =
        await ref.read(rewardClaimsRedeemedControllerProvider(widget.giverId).notifier).fulfill(widget.claim.id);
    if (!mounted) return;
    setState(() => _isActing = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as fulfilled.')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Future<void> _handleRequestRefund() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request refund'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for the refund'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(reasonController.text.trim()),
            child: const Text('Request'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;

    setState(() => _isActing = true);
    final result = await ref
        .read(rewardClaimsRedeemedControllerProvider(widget.giverId).notifier)
        .requestRefund(widget.claim.id, reason);
    if (!mounted) return;
    setState(() => _isActing = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund requested.')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(claim.rewardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'Redeemed ${claim.redeemedAt.toLocal().toString().split('.').first} · ${claim.price} pts',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  _statusLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _statusColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            if (claim.status == ClaimStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isActing ? null : _handleRequestRefund,
                    child: const Text('Request Refund'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isActing ? null : _handleFulfill,
                    child: _isActing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark Fulfilled'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
