import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';

class MyClaimsScreen extends StatelessWidget {
  final String giverId;

  const MyClaimsScreen({super.key, required this.giverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Claims')),
      body: _ClaimsList(giverId: giverId),
    );
  }
}

class _ClaimsList extends ConsumerWidget {
  final String giverId;

  const _ClaimsList({required this.giverId});

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
        return AppTheme.success;
      case ClaimStatus.refundRequested:
        return AppTheme.warning;
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
