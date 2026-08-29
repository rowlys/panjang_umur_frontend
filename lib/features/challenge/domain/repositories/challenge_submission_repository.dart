import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/proof_upload_slot.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_detail.dart';

abstract class ChallengeSubmissionRepository {
  Future<Result<Challenge>> submit(String challengeId, {String? proofImageId});
  Future<Result<List<ChallengeSubmission>>> getMySubmissions({String? statusFilter});
  Future<Result<List<SubmissionDetail>>> getSubmissionsFor(String challengeId);
  Future<Result<ChallengeSubmission>> approve(String submissionId);
  Future<Result<ProofUploadSlot>> getProofUploadSlot();
  Future<Result<void>> uploadProofImage({required String uploadUrl, required List<int> fileBytes});
}
