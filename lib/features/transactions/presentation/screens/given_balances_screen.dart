import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:panjang_umur_frontend/features/transactions/presentation/widgets/balance_tile.dart';

class GivenBalancesScreen extends ConsumerWidget {
  const GivenBalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(givenBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Who Holds My Points')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(givenBalancesProvider.future),
        child: balancesAsync.when(
          data: (all) {
            final balances = all.where((b) => b.balance > 0).toList();
            if (balances.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Nobody holds your points yet.')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: balances.length,
              itemBuilder: (context, index) {
                final balance = balances[index];
                return BalanceTile(
                  name: balance.ownerName,
                  username: balance.ownerUsername,
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
