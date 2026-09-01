import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/transactions/domain/models/transaction_entry.dart';
import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  TransactionDomainFilter? _selectedFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(transactionHistoryControllerProvider.notifier).loadHistory();
    });
  }

  void _selectFilter(TransactionDomainFilter? filter) {
    setState(() => _selectedFilter = filter);
    ref
        .read(transactionHistoryControllerProvider.notifier)
        .loadHistory(domainFilter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == null,
                  onSelected: () => _selectFilter(null),
                ),
                _FilterChip(
                  label: 'Rewards',
                  icon: Icons.card_giftcard,
                  selected: _selectedFilter == TransactionDomainFilter.rewards,
                  onSelected: () =>
                      _selectFilter(TransactionDomainFilter.rewards),
                ),
                _FilterChip(
                  label: 'Challenges',
                  icon: Icons.emoji_events_outlined,
                  selected:
                      _selectedFilter == TransactionDomainFilter.challenges,
                  onSelected: () =>
                      _selectFilter(TransactionDomainFilter.challenges),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(transactionHistoryControllerProvider.notifier)
                  .loadHistory(domainFilter: _selectedFilter),
              child: state.when(
                data: (page) {
                  if (page.entries.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Nothing here yet.')),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: page.entries.length + (page.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= page.entries.length) {
                        return _LoadMoreFooter(
                          isLoading: page.isLoadingMore,
                          onLoadMore: () => ref
                              .read(
                                transactionHistoryControllerProvider.notifier,
                              )
                              .loadMore(),
                        );
                      }
                      return _TransactionTile(entry: page.entries[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text('Failed to load history:\n$error')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: icon != null ? Icon(icon, size: 18) : null,
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntry entry;

  const _TransactionTile({required this.entry});

  IconData get _icon {
    switch (entry.referenceType) {
      case TransactionReferenceType.claim:
        return Icons.card_giftcard;
      case TransactionReferenceType.submission:
        return Icons.emoji_events_outlined;
    }
  }

  String get _subtitleVerb {
    switch (entry.label) {
      case 'Bought':
        return 'from';
      case 'Sold':
        return 'to';
      case 'Refunded':
        return 'by';
      case 'Refunded to buyer':
        return 'for';
      case 'Earned':
        return 'from';
      case 'Paid out':
        return 'to';
      default:
        return 'with';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color amountColor;
    String amountText;
    switch (entry.sign) {
      case TransactionSign.credit:
        amountColor = Colors.green;
        amountText = '+${entry.amount} pts';
      case TransactionSign.debit:
        amountColor = scheme.error;
        amountText = '-${entry.amount} pts';
      case TransactionSign.neutral:
        amountColor = scheme.onSurfaceVariant;
        amountText = '${entry.amount} pts';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(_icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${entry.label} $_subtitleVerb @${entry.counterpartyUsername} · '
                    '${entry.timestamp.toLocal().toString().split('.').first}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amountText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const _LoadMoreFooter({required this.isLoading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : TextButton(onPressed: onLoadMore, child: const Text('Load more')),
    );
  }
}
