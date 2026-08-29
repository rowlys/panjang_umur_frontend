import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_detail.dart';
import '../../domain/models/proof_upload_slot.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

const _submissionsPageSize = 20;

/// One page's worth of a challenge's submissions, plus enough state to
/// support "load more" pagination and toggling between pending-only and
/// full-history views without losing what's already been fetched.
class SubmissionsPage {
  final List<SubmissionDetail> submissions;
  final bool showAll;
  final bool hasMore;
  final bool isLoadingMore;

  const SubmissionsPage({
    required this.submissions,
    required this.showAll,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SubmissionsPage copyWith({
    List<SubmissionDetail>? submissions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SubmissionsPage(
      submissions: submissions ?? this.submissions,
      showAll: showAll,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages the submissions for a single challenge (used by the challenge
/// creator to review and approve them) plus the submit action performed by
/// an assignee/friend. Scoped to one challengeId via `.family`.
///
/// Submissions are creator-only on the backend, so `loadSubmissions` is NOT
/// called automatically on construction — only the creator-facing UI should
/// call it explicitly. Non-creator callers only ever use `submit()`.
class ChallengeSubmissionController extends StateNotifier<AsyncValue<SubmissionsPage>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String challengeId;

  ChallengeSubmissionController(this._submissionRepository, this.challengeId)
      : super(const AsyncValue.data(SubmissionsPage(submissions: [], showAll: false, hasMore: false)));

  /// Fetches the first page. Pass [showAll] to switch between pending-only
  /// (the default — what a creator needs to act on) and full history.
  Future<void> loadSubmissions({bool showAll = false}) async {
    state = const AsyncValue.loading();
    final result = await _submissionRepository.getSubmissionsFor(
      challengeId,
      statusFilter: showAll ? null : 'submitted',
      limit: _submissionsPageSize,
    );

    switch (result) {
      case Success(data: final submissions):
        state = AsyncValue.data(SubmissionsPage(
          submissions: submissions,
          showAll: showAll,
          // A full page suggests there's likely more; a short page means
          // we've hit the end. Simple and correct as long as the page size
          // itself never appears as a coincidental exact total count edge
          // case that matters (it doesn't here — worst case is one harmless
          // extra "Load more" tap that returns nothing).
          hasMore: submissions.length == _submissionsPageSize,
        ));
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  /// Fetches the next page using the last-loaded submission's timestamp as
  /// the cursor, and appends it to what's already shown.
  Future<Result<void>> loadMore() async {
    final page = state.valueOrNull;
    if (page == null || page.isLoadingMore || !page.hasMore || page.submissions.isEmpty) {
      return Success(null);
    }

    state = AsyncValue.data(page.copyWith(isLoadingMore: true));

    final result = await _submissionRepository.getSubmissionsFor(
      challengeId,
      statusFilter: page.showAll ? null : 'submitted',
      before: page.submissions.last.submittedAt,
      limit: _submissionsPageSize,
    );

    switch (result) {
      case Success(data: final more):
        state = AsyncValue.data(page.copyWith(
          submissions: [...page.submissions, ...more],
          hasMore: more.length == _submissionsPageSize,
          isLoadingMore: false,
        ));
        return Success(null);
      case Error(failure: final failure):
        state = AsyncValue.data(page.copyWith(isLoadingMore: false));
        return Error(failure);
    }
  }

  Future<Result<Challenge>> submit({List<int>? proofImageBytes}) async {
    String? proofImageId;

    if (proofImageBytes != null) {
      final slotResult = await _submissionRepository.getProofUploadSlot();
      if (slotResult is Error<ProofUploadSlot>) {
        return Error(slotResult.failure);
      }

      final slot = (slotResult as Success<ProofUploadSlot>).data;
      
      final uploadResult = await _submissionRepository.uploadProofImage(
        uploadUrl: slot.uploadUrl,
        fileBytes: proofImageBytes,
      );

      if (uploadResult is Error<void>) {
        return Error(uploadResult.failure);
      }

      proofImageId = slot.imageId;
    }

    return _submissionRepository.submit(challengeId, proofImageId: proofImageId);
  }

  Future<Result<ChallengeSubmission>> approve(String submissionId) async {
    final result = await _submissionRepository.approve(submissionId);
    if (result is Success<ChallengeSubmission>) {
      await loadSubmissions(showAll: state.valueOrNull?.showAll ?? false);
    }
    return result;
  }
}
