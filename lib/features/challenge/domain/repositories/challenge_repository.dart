import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/assigned_challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_detail.dart';

abstract class ChallengeRepository {
  Future<Result<List<Challenge>>> getCreatedByMe();
  Future<Result<List<AssignedChallenge>>> getAssignedToMe();
  Future<Result<ChallengeDetail>> getById(String id);

  Future<Result<Challenge>> create({
    required String title,
    required String description,
    required int points,
    required ChallengeType type,
    int? resetDay,
    List<String> assigneeIds,
    DateTime? expiresAt,
  });

  Future<Result<Challenge>> cancel(String challengeId);
}
