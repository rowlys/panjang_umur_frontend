import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/transaction_entry.dart';
import '../../domain/repositories/transaction_repository.dart';

const _historyPageSize = 20;

class TransactionHistoryPage {
  final List<TransactionEntry> entries;
  final TransactionDomainFilter? domainFilter;
  final bool hasMore;
  final bool isLoadingMore;

  const TransactionHistoryPage({
    required this.entries,
    this.domainFilter,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  TransactionHistoryPage copyWith({
    List<TransactionEntry>? entries,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TransactionHistoryPage(
      entries: entries ?? this.entries,
      domainFilter: domainFilter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// The full point-movement ledger (History screen): every transaction the
/// caller took part in, optionally narrowed to one domain.
class TransactionHistoryController
    extends StateNotifier<AsyncValue<TransactionHistoryPage>> {
  final TransactionRepository _transactionRepository;

  TransactionHistoryController(this._transactionRepository)
    : super(
        const AsyncValue.data(
          TransactionHistoryPage(entries: [], hasMore: false),
        ),
      );

  Future<void> loadHistory({TransactionDomainFilter? domainFilter}) async {
    state = const AsyncValue.loading();
    final result = await _transactionRepository.getHistory(
      domainFilter: domainFilter,
      limit: _historyPageSize,
    );

    switch (result) {
      case Success(data: final entries):
        state = AsyncValue.data(
          TransactionHistoryPage(
            entries: entries,
            domainFilter: domainFilter,
            hasMore: entries.length == _historyPageSize,
          ),
        );
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> loadMore() async {
    final page = state.valueOrNull;
    if (page == null ||
        page.isLoadingMore ||
        !page.hasMore ||
        page.entries.isEmpty) {
      return;
    }

    state = AsyncValue.data(page.copyWith(isLoadingMore: true));

    final result = await _transactionRepository.getHistory(
      domainFilter: page.domainFilter,
      before: page.entries.last.timestamp,
      limit: _historyPageSize,
    );

    switch (result) {
      case Success(data: final more):
        state = AsyncValue.data(
          page.copyWith(
            entries: [...page.entries, ...more],
            hasMore: more.length == _historyPageSize,
            isLoadingMore: false,
          ),
        );
      case Error():
        state = AsyncValue.data(page.copyWith(isLoadingMore: false));
    }
  }
}
