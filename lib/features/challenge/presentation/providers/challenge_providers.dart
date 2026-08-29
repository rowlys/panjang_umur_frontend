import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:panjang_umur_frontend/core/providers/core_providers.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/assigned_challenge.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_detail.dart';
import '../../domain/models/submission_detail.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/challenge_submission_repository.dart';
import '../../data/datasources/challenge_remote_datasource.dart';
import '../../data/datasources/challenge_submission_remote_datasource.dart';
import '../../data/datasources/proof_image_upload_datasource.dart';
import '../../data/repositories/challenge_repository_impl.dart';
import '../../data/repositories/challenge_submission_repository_impl.dart';
import '../controllers/created_challenge_controller.dart';
import '../controllers/assigned_challenge_controller.dart';
import '../controllers/challenge_submission_controller.dart';

final challengeRemoteDataSourceProvider = Provider<ChallengeRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChallengeRemoteDataSource(client: dioClient);
});

final challengeSubmissionRemoteDataSourceProvider = Provider<ChallengeSubmissionRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChallengeSubmissionRemoteDataSource(client: dioClient);
});

final proofImageUploadDataSourceProvider = Provider<ProofImageUploadDataSource>((ref) {
  return ProofImageUploadDataSource(dio: Dio());
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final challengeRemoteDataSource = ref.watch(challengeRemoteDataSourceProvider);
  return ChallengeRepositoryImpl(challengeRemoteDataSource);
});

final challengeSubmissionRepositoryProvider = Provider<ChallengeSubmissionRepository>((ref) {
  final challengeSubmissionRemoteDataSource = ref.watch(challengeSubmissionRemoteDataSourceProvider);
  final proofImageUploadDataSource = ref.watch(proofImageUploadDataSourceProvider);
  return ChallengeSubmissionRepositoryImpl(challengeSubmissionRemoteDataSource, proofImageUploadDataSource);
});

final createdChallengeControllerProvider = StateNotifierProvider.autoDispose<CreatedChallengeController, AsyncValue<List<Challenge>>>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  return CreatedChallengeController(challengeRepository);
});

final assignedChallengeControllerProvider = StateNotifierProvider.autoDispose<AssignedChallengeController, AsyncValue<List<AssignedChallenge>>>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  return AssignedChallengeController(challengeRepository);
});

final challengeSubmissionControllerProvider = StateNotifierProvider.autoDispose
    .family<ChallengeSubmissionController, AsyncValue<List<SubmissionDetail>>, String>((ref, challengeId) {
  final submissionRepository = ref.watch(challengeSubmissionRepositoryProvider);
  return ChallengeSubmissionController(submissionRepository, challengeId);
});

final challengeDetailProvider = FutureProvider.autoDispose.family<ChallengeDetail, String>((ref, id) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final result = await repository.getById(id);

  switch (result) {
    case Success(data: final challenge):
      return challenge;
    case Error(failure: final error):
      throw Exception(error.message);
  }
});
