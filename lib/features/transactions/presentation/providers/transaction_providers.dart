import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/providers/core_providers.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/given_balance.dart';
import '../../domain/models/point_balance.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../controllers/transaction_history_controller.dart';

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return TransactionRemoteDataSource(client: dioClient);
    });

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final transactionRemoteDataSource = ref.watch(
    transactionRemoteDataSourceProvider,
  );
  return TransactionRepositoryImpl(transactionRemoteDataSource);
});

final transactionHistoryControllerProvider =
    StateNotifierProvider.autoDispose<
      TransactionHistoryController,
      AsyncValue<TransactionHistoryPage>
    >((ref) {
      final transactionRepository = ref.watch(transactionRepositoryProvider);
      return TransactionHistoryController(transactionRepository);
    });

final balancesProvider = FutureProvider.autoDispose<List<PointBalance>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getBalances();

  switch (result) {
    case Success(data: final balances):
      return balances;
    case Error(failure: final error):
      throw Exception(error.message);
  }
});

final balanceForGiverProvider = Provider.autoDispose.family<AsyncValue<PointBalance?>, String>((
  ref,
  giverId,
) {
  final balances = ref.watch(balancesProvider);
  return balances.whenData((list) {
    for (final balance in list) {
      if (balance.giverId == giverId) return balance;
    }
    return null;
  });
});

final givenBalancesProvider = FutureProvider.autoDispose<List<GivenBalance>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getGivenBalances();

  switch (result) {
    case Success(data: final balances):
      return balances;
    case Error(failure: final error):
      throw Exception(error.message);
  }
});

final givenBalanceForOwnerProvider = Provider.autoDispose.family<AsyncValue<GivenBalance?>, String>((
  ref,
  ownerId,
) {
  final balances = ref.watch(givenBalancesProvider);
  return balances.whenData((list) {
    for (final balance in list) {
      if (balance.ownerId == ownerId) return balance;
    }
    return null;
  });
});
