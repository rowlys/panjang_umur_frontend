import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/providers/core_providers.dart';

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
