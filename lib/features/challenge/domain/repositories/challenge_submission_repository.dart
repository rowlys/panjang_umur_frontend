import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/proof_upload_slot.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_received.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_submitted.dart';

abstract class ChallengeSubmissionRepository {
  Future<Result<Challenge>> submit(String challengeId, {String? proofImageId});

  Future<Result<List<SubmissionSubmitted>>> getSubmissionsSubmitted({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  });

  Future<Result<List<SubmissionReceived>>> getSubmissionsReceived({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  });

  Future<Result<ChallengeSubmission>> approve(String submissionId);
  Future<Result<ProofUploadSlot>> getProofUploadSlot();
  Future<Result<void>> uploadProofImage({required String uploadUrl, required List<int> fileBytes});
}
