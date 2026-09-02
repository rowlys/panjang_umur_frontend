import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/transactions/domain/models/point_balance.dart';
import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';

class BalancesScreen extends ConsumerWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(balancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Balances')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(balancesProvider.future),
        child: balancesAsync.when(
          data: (balances) {
            if (balances.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text("You don't hold points with anyone yet.")),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: balances.length,
              itemBuilder: (context, index) => _BalanceTile(balance: balances[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(child: Text('Failed to load balances:\n$error')),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final PointBalance balance;

  const _BalanceTile({required this.balance});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(
            balance.giverName.isNotEmpty ? balance.giverName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(balance.giverName),
        subtitle: Text('@${balance.giverUsername}'),
        trailing: Text(
          '${balance.balance} pts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}
