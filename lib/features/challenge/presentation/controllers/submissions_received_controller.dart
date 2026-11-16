import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_received.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

const _submissionsPageSize = 20;

/// One page of received submissions, with pagination and filter state.
class SubmissionsReceivedPage {
  final List<SubmissionReceived> submissions;
  final bool showAll;
  final bool hasMore;
  final bool isLoadingMore;

  const SubmissionsReceivedPage({
    required this.submissions,
    required this.showAll,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SubmissionsReceivedPage copyWith({
    List<SubmissionReceived>? submissions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SubmissionsReceivedPage(
      submissions: submissions ?? this.submissions,
      showAll: showAll,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages submissions made on challenges I created (I'm the reviewer).
class SubmissionsReceivedController
    extends StateNotifier<AsyncValue<SubmissionsReceivedPage>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String? challengeId;

  SubmissionsReceivedController(this._submissionRepository, {this.challengeId})
    : super(const AsyncValue.loading());

  Future<void> loadSubmissions({bool showAll = false}) async {
    state = AsyncValue<SubmissionsReceivedPage>.loading().copyWithPrevious(state);
    final result = await _submissionRepository.getSubmissionsReceived(
      challengeId: challengeId,
      statusFilter: showAll ? null : 'submitted',
      limit: _submissionsPageSize,
    );

    if (!mounted) return;

    switch (result) {
      case Success(data: final submissions):
        state = AsyncValue.data(
          SubmissionsReceivedPage(
            submissions: submissions,
            showAll: showAll,
            hasMore: submissions.length == _submissionsPageSize,
          ),
        );
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<void>> loadMore() async {
    final page = state.valueOrNull;
    if (page == null ||
        page.isLoadingMore ||
        !page.hasMore ||
        page.submissions.isEmpty) {
      return Success(null);
    }

    state = AsyncValue.data(page.copyWith(isLoadingMore: true));

    final result = await _submissionRepository.getSubmissionsReceived(
      challengeId: challengeId,
      statusFilter: page.showAll ? null : 'submitted',
      before: page.submissions.last.submittedAt,
      limit: _submissionsPageSize,
    );

    if (!mounted) return Success(null);

    switch (result) {
      case Success(data: final more):
        state = AsyncValue.data(
          page.copyWith(
            submissions: [...page.submissions, ...more],
            hasMore: more.length == _submissionsPageSize,
            isLoadingMore: false,
          ),
        );
        return Success(null);
      case Error(failure: final failure):
        state = AsyncValue.data(page.copyWith(isLoadingMore: false));
        return Error(failure);
    }
  }

  /// Approves a submission optimistically: the row changes immediately and is
  /// put back only if the server refuses. No reload happens, so approving a long
  /// list stays instant.
  Future<Result<ChallengeSubmission>> approve(String submissionId) async {
    final page = state.valueOrNull;
    SubmissionReceived? previous;
    var previousIndex = -1;

    if (page != null) {
      final index = page.submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        previous = page.submissions[index];
        previousIndex = index;
        markApprovedLocally(submissionId);
      }
    }

    final result = await _submissionRepository.approve(submissionId);
    if (!mounted) return result;

    if (result is Error && previous != null) {
      _rollback(previous, previousIndex);
    }
    return result;
  }

  /// Mirrors an approval that happened through another list (for example the
  /// challenge detail page) so the badge count stays correct, without fetching.
  void markApprovedLocally(String submissionId) {
    final page = state.valueOrNull;
    if (page == null) return;

    final index = page.submissions.indexWhere((s) => s.id == submissionId);
    if (index == -1) return;

    if (page.showAll) {
      final next = [...page.submissions];
      next[index] = next[index].copyWith(status: SubmissionStatus.approved);
      state = AsyncValue.data(page.copyWith(submissions: next));
    } else {
      state = AsyncValue.data(
        page.copyWith(submissions: [...page.submissions]..removeAt(index)),
      );
    }
  }

  void _rollback(SubmissionReceived previous, int previousIndex) {
    final page = state.valueOrNull;
    if (page == null) return;

    final next = [...page.submissions];
    final index = next.indexWhere((s) => s.id == previous.id);
    if (index == -1) {
      next.insert(min(previousIndex, next.length), previous);
    } else {
      next[index] = previous;
    }
    state = AsyncValue.data(page.copyWith(submissions: next));
  }
}
