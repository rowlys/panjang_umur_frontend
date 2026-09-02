import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/features/transactions/domain/models/point_balance.dart';
import 'package:panjang_umur_frontend/features/transactions/domain/models/transaction_entry.dart';
import 'package:panjang_umur_frontend/features/transactions/domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _transactionRemoteDataSource;

  TransactionRepositoryImpl(this._transactionRemoteDataSource);

  @override
  Future<Result<List<TransactionEntry>>> getHistory({
    TransactionDomainFilter? domainFilter,
    DateTime? before,
    int? limit,
  }) async {
    try {
      final entries = await _transactionRemoteDataSource.getHistory(
        domainFilter: domainFilter,
        before: before,
        limit: limit,
      );
      return Success(entries);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<PointBalance>>> getBalances() async {
    try {
      final balances = await _transactionRemoteDataSource.getBalances();
      return Success(balances);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
