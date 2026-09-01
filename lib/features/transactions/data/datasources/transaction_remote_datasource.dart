import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/features/transactions/domain/models/transaction_entry.dart';

class TransactionRemoteDataSource {
  final DioClient _client;

  TransactionRemoteDataSource({required this._client});

  Future<List<TransactionEntry>> getHistory({
    TransactionDomainFilter? domainFilter,
    DateTime? before,
    int? limit,
  }) async {
    final response = await _client.get(
      '/transactions/me',
      queryParameters: {
        'type': ?domainFilter?.queryValue,
        'before': ?before?.toUtc().toIso8601String(),
        'limit': ?limit?.toString(),
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => TransactionEntry.fromJson(json)).toList();
  }
}
