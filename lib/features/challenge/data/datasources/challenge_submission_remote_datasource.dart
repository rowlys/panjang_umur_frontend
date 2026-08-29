import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/proof_upload_slot.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_detail.dart';

class ChallengeSubmissionRemoteDataSource {
  final DioClient _client;

  ChallengeSubmissionRemoteDataSource({required this._client});

  Future<Challenge> submit(String challengeId, {String? proofImageId}) async {
    final response = await _client.patch(
      '/challenges/$challengeId/submit',
      data: {'proofImageId': ?proofImageId},
    );
    return Challenge.fromJson(response.data);
  }

  Future<List<ChallengeSubmission>> getMySubmissions({String? statusFilter}) async {
    final response = await _client.get(
      '/challenges/submissions/me',
      queryParameters: statusFilter != null ? {'status': statusFilter} : null,
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ChallengeSubmission.fromJson(json)).toList();
  }

  Future<List<SubmissionDetail>> getSubmissionsFor(
    String challengeId, {
    String? statusFilter,
    DateTime? before,
    int? limit,
  }) async {
    final response = await _client.get(
      '/challenges/submissions/$challengeId',
      queryParameters: {
        'status': ?statusFilter,
        'before': ?before?.toUtc().toIso8601String(),
        'limit': ?limit?.toString(),
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => SubmissionDetail.fromJson(json)).toList();
  }

  Future<ChallengeSubmission> approve(String submissionId) async {
    final response = await _client.patch('/challenges/submissions/$submissionId/approve');
    return ChallengeSubmission.fromJson(response.data);
  }

  Future<ProofUploadSlot> getProofUploadSlot() async {
    final response = await _client.get('/challenges/proof-upload-url');
    return ProofUploadSlot.fromJson(response.data);
  }
}
