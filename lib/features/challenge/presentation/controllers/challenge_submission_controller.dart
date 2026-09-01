import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/proof_upload_slot.dart';
import '../../domain/repositories/challenge_submission_repository.dart';

/// Handles submitting proof for a single challenge (the assignee's action).
class ChallengeSubmissionController extends StateNotifier<AsyncValue<void>> {
  final ChallengeSubmissionRepository _submissionRepository;
  final String challengeId;

  ChallengeSubmissionController(this._submissionRepository, this.challengeId)
    : super(const AsyncValue.data(null));

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
}
