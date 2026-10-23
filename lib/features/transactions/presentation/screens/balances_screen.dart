import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:panjang_umur_frontend/features/transactions/presentation/widgets/balance_tile.dart';

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
              itemBuilder: (context, index) {
                final balance = balances[index];
                return BalanceTile(
                  name: balance.giverName,
                  username: balance.giverUsername,
                  balance: balance.balance,
                );
              },
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
