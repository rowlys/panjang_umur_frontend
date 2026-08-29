import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/features/challenge/domain/models/assigned_challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_detail.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_datasource.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource _challengeRemoteDataSource;

  ChallengeRepositoryImpl(this._challengeRemoteDataSource);

  @override
  Future<Result<List<Challenge>>> getCreatedByMe() async {
    try {
      final challenges = await _challengeRemoteDataSource.getCreatedByMe();
      return Success(challenges);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AssignedChallenge>>> getAssignedToMe() async {
    try {
      final challenges = await _challengeRemoteDataSource.getAssignedToMe();
      return Success(challenges);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChallengeDetail>> getById(String id) async {
    try {
      final challenge = await _challengeRemoteDataSource.getById(id);
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
  Future<Result<Challenge>> create({
    required String title,
    required String description,
    required int points,
    required ChallengeType type,
    int? resetDay,
    List<String> assigneeIds = const [],
    DateTime? expiresAt,
  }) async {
    try {
      final challenge = await _challengeRemoteDataSource.create(
        title: title,
        description: description,
        points: points,
        type: type,
        resetDay: resetDay,
        assigneeIds: assigneeIds,
        expiresAt: expiresAt,
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
  Future<Result<Challenge>> cancel(String challengeId) async {
    try {
      final challenge = await _challengeRemoteDataSource.cancel(challengeId);
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
  Future<Result<void>> delete(String challengeId) async {
    try {
      await _challengeRemoteDataSource.delete(challengeId);
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
