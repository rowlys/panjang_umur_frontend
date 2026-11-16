import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge.dart';
import '../../domain/repositories/challenge_repository.dart';

class CreatedChallengeController extends StateNotifier<AsyncValue<List<Challenge>>> {
  final ChallengeRepository _challengeRepository;

  CreatedChallengeController(this._challengeRepository) : super(const AsyncValue.loading()) {
    getCreatedByMe();
  }

  Future<void> getCreatedByMe() async {
    state = AsyncValue<List<Challenge>>.loading().copyWithPrevious(state);
    final result = await _challengeRepository.getCreatedByMe();

    if (!mounted) return;

    switch (result) {
      case Success(data: final challenges):
        state = AsyncValue.data(challenges);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<Challenge>> create({
    required String title,
    required String description,
    required int points,
    required ChallengeType type,
    int? resetDay,
    List<String> assigneeIds = const [],
    DateTime? expiresAt,
  }) async {
    final result = await _challengeRepository.create(
      title: title,
      description: description,
      points: points,
      type: type,
      resetDay: resetDay,
      assigneeIds: assigneeIds,
      expiresAt: expiresAt,
    );

    if (result is Success<Challenge>) {
      _upsert(result.data);
    }
    return result;
  }

  Future<Result<Challenge>> update(
    String challengeId, {
    String? title,
    String? description,
    int? points,
    DateTime? expiresAt,
  }) async {
    final result = await _challengeRepository.update(
      challengeId,
      title: title,
      description: description,
      points: points,
      expiresAt: expiresAt,
    );

    if (result is Success<Challenge>) {
      _upsert(result.data);
    }
    return result;
  }

  Future<Result<Challenge>> cancel(String challengeId) async {
    final result = await _challengeRepository.cancel(challengeId);

    if (result is Success<Challenge>) {
      _upsert(result.data);
    }
    return result;
  }

  /// Replaces the challenge in place, or adds it when it is new, so the board
  /// updates without a reload.
  void _upsert(Challenge challenge) {
    if (!mounted) return;
    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.indexWhere((entry) => entry.id == challenge.id);
    if (index == -1) {
      state = AsyncValue.data([challenge, ...current]);
      return;
    }

    final next = [...current];
    next[index] = challenge;
    state = AsyncValue.data(next);
  }
}
