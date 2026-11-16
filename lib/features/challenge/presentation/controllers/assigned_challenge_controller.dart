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
    state = AsyncValue<List<AssignedChallenge>>.loading().copyWithPrevious(state);
    final result = await _challengeRepository.getAssignedToMe();

    if (!mounted) return;

    switch (result) {
      case Success(data: final challenges):
        state = AsyncValue.data(challenges);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  /// Drops a challenge from the list right after its submission is accepted,
  /// without refetching the board.
  void markSubmitted(String challengeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.where((challenge) => challenge.id != challengeId).toList());
  }
}
