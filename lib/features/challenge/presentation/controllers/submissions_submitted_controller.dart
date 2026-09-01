import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/submission_submitted.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

const _submissionsPageSize = 20;

/// One page of submissions I've made, with pagination and filter state.
class SubmissionsSubmittedPage {
  final List<SubmissionSubmitted> submissions;
  final bool showAll;
  final bool hasMore;
  final bool isLoadingMore;

  const SubmissionsSubmittedPage({
    required this.submissions,
    required this.showAll,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SubmissionsSubmittedPage copyWith({
    List<SubmissionSubmitted>? submissions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SubmissionsSubmittedPage(
      submissions: submissions ?? this.submissions,
      showAll: showAll,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages submissions I've made (I'm the submitter).
class SubmissionsSubmittedController
    extends StateNotifier<AsyncValue<SubmissionsSubmittedPage>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String? challengeId;

  SubmissionsSubmittedController(this._submissionRepository, {this.challengeId})
    : super(
        const AsyncValue.data(
          SubmissionsSubmittedPage(
            submissions: [],
            showAll: true,
            hasMore: false,
          ),
        ),
      );

  Future<void> loadSubmissions({bool showAll = true}) async {
    state = const AsyncValue.loading();
    final result = await _submissionRepository.getSubmissionsSubmitted(
      challengeId: challengeId,
      statusFilter: showAll ? null : 'submitted',
      limit: _submissionsPageSize,
    );

    switch (result) {
      case Success(data: final submissions):
        state = AsyncValue.data(
          SubmissionsSubmittedPage(
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

    final result = await _submissionRepository.getSubmissionsSubmitted(
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
}
