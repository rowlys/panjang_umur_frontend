import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/transactions/domain/models/point_balance.dart';
import 'package:panjang_umur_frontend/features/transactions/domain/models/transaction_entry.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntry>>> getHistory({
    TransactionDomainFilter? domainFilter,
    DateTime? before,
    int? limit,
  });

  Future<Result<List<PointBalance>>> getBalances();
}
