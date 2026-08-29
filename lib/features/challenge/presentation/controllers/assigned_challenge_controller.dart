import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/assigned_challenge.dart';
import '../../domain/repositories/challenge_repository.dart';

class AssignedChallengeController extends StateNotifier<AsyncValue<List<AssignedChallenge>>> {
  final ChallengeRepository _challengeRepository;

  AssignedChallengeController(this._challengeRepository) : super(const AsyncValue.loading()) {
    getAssignedToMe();
  }

  Future<void> getAssignedToMe() async {
    state = const AsyncValue.loading();
    final result = await _challengeRepository.getAssignedToMe();

    switch (result) {
      case Success(data: final challenges):
        state = AsyncValue.data(challenges);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }
}
