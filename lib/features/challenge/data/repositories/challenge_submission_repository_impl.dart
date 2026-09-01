import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/proof_upload_slot.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_received.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_submitted.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/repositories/challenge_submission_repository.dart';
import '../datasources/challenge_submission_remote_datasource.dart';
import '../datasources/proof_image_upload_datasource.dart';

class ChallengeSubmissionRepositoryImpl implements ChallengeSubmissionRepository {
  final ChallengeSubmissionRemoteDataSource _challengeSubmissionRemoteDataSource;
  final ProofImageUploadDataSource _proofImageUploadDataSource;

  ChallengeSubmissionRepositoryImpl(this._challengeSubmissionRemoteDataSource, this._proofImageUploadDataSource);

  @override
  Future<Result<Challenge>> submit(String challengeId, {String? proofImageId}) async {
    try {
      final challenge = await _challengeSubmissionRemoteDataSource.submit(
        challengeId,
        proofImageId: proofImageId,
      );
      return Success(challenge);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SubmissionSubmitted>>> getSubmissionsSubmitted({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  }) async {
    try {
      final submissions = await _challengeSubmissionRemoteDataSource
          .getSubmissionsSubmitted(
            challengeId: challengeId,
            statusFilter: statusFilter,
            before: before,
            limit: limit,
          );
      return Success(submissions);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SubmissionReceived>>> getSubmissionsReceived({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  }) async {
    try {
      final submissions = await _challengeSubmissionRemoteDataSource
          .getSubmissionsReceived(
            challengeId: challengeId,
            statusFilter: statusFilter,
            before: before,
            limit: limit,
          );
      return Success(submissions);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChallengeSubmission>> approve(String submissionId) async {
    try {
      final submission = await _challengeSubmissionRemoteDataSource.approve(submissionId);
      return Success(submission);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProofUploadSlot>> getProofUploadSlot() async {
    try {
      final slot = await _challengeSubmissionRemoteDataSource.getProofUploadSlot();
      return Success(slot);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> uploadProofImage({required String uploadUrl, required List<int> fileBytes}) async {
    try {
      await _proofImageUploadDataSource.upload(uploadUrl: uploadUrl, fileBytes: fileBytes);
      return Success(null);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
