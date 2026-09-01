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
    : super(
        const AsyncValue.data(
          SubmissionsReceivedPage(
            submissions: [],
            showAll: false,
            hasMore: false,
          ),
        ),
      );

  Future<void> loadSubmissions({bool showAll = false}) async {
    state = const AsyncValue.loading();
    final result = await _submissionRepository.getSubmissionsReceived(
      challengeId: challengeId,
      statusFilter: showAll ? null : 'submitted',
      limit: _submissionsPageSize,
    );

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

  Future<Result<ChallengeSubmission>> approve(String submissionId) async {
    final result = await _submissionRepository.approve(submissionId);
    if (result is Success<ChallengeSubmission>) {
      await loadSubmissions(showAll: state.valueOrNull?.showAll ?? false);
    }
    return result;
  }
}
