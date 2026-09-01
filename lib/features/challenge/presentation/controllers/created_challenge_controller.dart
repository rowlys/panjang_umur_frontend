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
    state = const AsyncValue.loading();
    final result = await _challengeRepository.getCreatedByMe();

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
      await getCreatedByMe();
    }
    return result;
  }

  Future<void> cancel(String challengeId) async {
    state = const AsyncValue.loading();
    final result = await _challengeRepository.cancel(challengeId);

    switch (result) {
      case Success():
        await getCreatedByMe();
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }
}
