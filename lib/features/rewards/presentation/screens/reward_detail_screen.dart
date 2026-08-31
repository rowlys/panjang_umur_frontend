import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';

class RewardDetailScreen extends ConsumerWidget {
  final String id;

  const RewardDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardAsync = ref.watch(rewardDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Reward')),
      body: rewardAsync.when(
        data: (reward) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(rewardDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  reward.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (reward.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(reward.description),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${reward.cost} pts')),
                    Chip(
                      label: Text(reward.visibility == RewardVisibility.restricted ? 'Restricted' : 'Public'),
                    ),
                    Chip(
                      label: Text(reward.isAvailable ? 'Available' : 'Unavailable'),
                      backgroundColor: reward.isAvailable
                          ? null
                          : Theme.of(context).colorScheme.errorContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _StockEditor(rewardId: id, currentStock: reward.stock),
                const SizedBox(height: 24),
                Text('Claims', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _ClaimsSection(rewardId: id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load reward:\n$error')),
      ),
    );
  }
}

class _StockEditor extends ConsumerStatefulWidget {
  final String rewardId;
  final int currentStock;

  const _StockEditor({required this.rewardId, required this.currentStock});

  @override
  ConsumerState<_StockEditor> createState() => _StockEditorState();
}

class _StockEditorState extends ConsumerState<_StockEditor> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentStock.toString());
  }

  @override
  void didUpdateWidget(covariant _StockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStock != widget.currentStock && !_isSaving) {
      _controller.text = widget.currentStock.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final stock = int.tryParse(_controller.text.trim());
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid stock amount (0 or more).')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final result = await ref.read(myShopControllerProvider.notifier).updateStock(widget.rewardId, stock);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ref.invalidate(rewardDetailProvider(widget.rewardId));

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated.')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stock', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Stock'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Setting stock to 0 makes this reward unavailable. Raising it back above 0 makes it available again.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ClaimsSection extends ConsumerWidget {
  final String rewardId;

  const _ClaimsSection({required this.rewardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsState = ref.watch(rewardClaimsControllerProvider(rewardId));

    return claimsState.when(
      data: (page) {
        if (page.claims.isEmpty) {
          return const Text('No claims yet.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...page.claims.map((claim) => _ClaimTile(claim: claim)),
            if (page.hasMore)
              Center(
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
                        onPressed: () => ref.read(rewardClaimsControllerProvider(rewardId).notifier).loadMore(),
                        child: const Text('Load more'),
                      ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Failed to load claims:\n$error'),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  final RewardClaim claim;

  const _ClaimTile({required this.claim});

  String get _statusLabel {
    switch (claim.status) {
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
    switch (claim.status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(
                claim.redeemerUsername.isNotEmpty ? claim.redeemerUsername[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@${claim.redeemerUsername}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Redeemed ${claim.redeemedAt.toLocal().toString().split('.').first}',
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
      ),
    );
  }
}
