import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_detail.dart';
import '../../domain/models/proof_upload_slot.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

const _submissionsPageSize = 20;

/// One page of a challenge's submissions, with pagination and filter state.
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

/// Manages submissions for a single challenge, fetched by challengeId.
class ChallengeSubmissionController extends StateNotifier<AsyncValue<SubmissionsPage>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String challengeId;

  ChallengeSubmissionController(this._submissionRepository, this.challengeId)
      : super(const AsyncValue.data(SubmissionsPage(submissions: [], showAll: false, hasMore: false)));

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
          hasMore: submissions.length == _submissionsPageSize,
        ));
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

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
