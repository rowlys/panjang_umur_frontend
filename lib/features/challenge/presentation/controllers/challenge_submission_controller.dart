import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_detail.dart';
import '../../domain/models/proof_upload_slot.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

/// Manages the submissions for a single challenge (used by the challenge
/// creator to review and approve them) plus the submit action performed by
/// an assignee/friend. Scoped to one challengeId via `.family`.
///
/// Submissions are creator-only on the backend, so `loadSubmissions` is NOT
/// called automatically on construction — only the creator-facing UI should
/// call it explicitly. Non-creator callers only ever use `submit()`.
class ChallengeSubmissionController extends StateNotifier<AsyncValue<List<SubmissionDetail>>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String challengeId;

  ChallengeSubmissionController(this._submissionRepository, this.challengeId)
      : super(const AsyncValue.data([]));

  Future<void> loadSubmissions() async {
    state = const AsyncValue.loading();
    final result = await _submissionRepository.getSubmissionsFor(challengeId);

    switch (result) {
      case Success(data: final submissions):
        state = AsyncValue.data(submissions);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
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
      await loadSubmissions();
    }
    return result;
  }
}
