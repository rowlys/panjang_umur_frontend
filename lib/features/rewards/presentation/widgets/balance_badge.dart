import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';

class BalanceBadge extends ConsumerWidget {
  final String giverId;

  const BalanceBadge({super.key, required this.giverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceForGiverProvider(giverId));
    final scheme = Theme.of(context).colorScheme;

    final label = balanceAsync.when(
      data: (balance) => '${balance?.balance ?? 0} pts',
      loading: () => '… pts',
      error: (error, _) => '? pts',
    );

    return Chip(
      avatar: Icon(Icons.account_balance_wallet_rounded, size: 18, color: scheme.onPrimaryContainer),
      label: Text(label),
      backgroundColor: scheme.primaryContainer,
      labelStyle: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
      side: BorderSide.none,
    );
  }
}
