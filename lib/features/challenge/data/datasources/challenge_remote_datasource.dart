import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/assigned_challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_detail.dart';

class ChallengeRemoteDataSource {
  final DioClient _client;

  ChallengeRemoteDataSource({required this._client});

  Future<List<Challenge>> getCreatedByMe() async {
    final response = await _client.get('/challenges/me/created');
    final List<dynamic> data = response.data;
    return data.map((json) => Challenge.fromJson(json)).toList();
  }

  Future<List<AssignedChallenge>> getAssignedToMe() async {
    final response = await _client.get('/challenges/me');
    final List<dynamic> data = response.data;
    return data.map((json) => AssignedChallenge.fromJson(json)).toList();
  }

  Future<ChallengeDetail> getById(String id) async {
    final response = await _client.get('/challenges/$id');
    return ChallengeDetail.fromJson(response.data);
  }

  Future<Challenge> create({
    required String title,
    required String description,
    required int points,
    required ChallengeType type,
    int? resetDay,
    List<String> assigneeIds = const [],
    DateTime? expiresAt,
  }) async {
    final response = await _client.post('/challenges', data: {
      'title': title,
      'description': description,
      'points': points,
      'type': type.index,
      'resetDay': ?resetDay,
      'assigneeIds': assigneeIds,
      if (expiresAt != null) 'expiresAt': expiresAt.toUtc().toIso8601String(),
    });
    return Challenge.fromJson(response.data);
  }

  Future<Challenge> cancel(String challengeId) async {
    final response = await _client.patch('/challenges/$challengeId/cancel');
    return Challenge.fromJson(response.data);
  }

  Future<void> delete(String challengeId) async {
    await _client.delete('/challenges/$challengeId');
  }
}
