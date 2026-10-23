import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';
import '../widgets/reward_shelf.dart';
import '../widgets/shop_pages.dart';
import '../widgets/shop_stand.dart';

class MyStoreScreen extends ConsumerWidget {
  const MyStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myShopControllerProvider);

    Widget page(Iterable<Reward> rewards, String emptyMessage) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myShopControllerProvider.notifier).getMyShop(),
        child: rewards.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(emptyMessage)),
                ],
              )
            : RewardShelf(rewards: rewards.toList(), onTap: (reward) => context.push('/rewards/${reward.id}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Store'),
        actions: [
          IconButton(
            onPressed: () => context.push('/balances/given'),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Who holds my points',
          ),
        ],
      ),
      body: ShopStand(
        shopkeeper: ref.watch(authControllerProvider).valueOrNull?.gender,
        child: state.when(
          data: (rewards) => ShopPages(
            children: [
              page(rewards.where((r) => r.isAvailable), "You don't have any available rewards."),
              page(rewards.where((r) => !r.isAvailable), 'No unavailable rewards.'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => RefreshIndicator(
            onRefresh: () => ref.read(myShopControllerProvider.notifier).getMyShop(),
            child: ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text('Failed to load your store:\n$error')),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/rewards/new'),
          icon: const Icon(Icons.add),
          label: const Text('New Reward'),
        ),
      ),
    );
  }
}
