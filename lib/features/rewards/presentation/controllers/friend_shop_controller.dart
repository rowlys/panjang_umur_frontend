import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/reward.dart';
import '../../domain/repositories/reward_repository.dart';

class FriendShopController extends StateNotifier<AsyncValue<List<Reward>>> {
  final RewardRepository _rewardRepository;
  final String giverId;

  FriendShopController(this._rewardRepository, this.giverId) : super(const AsyncValue.loading()) {
    getShop();
  }

  Future<void> getShop() async {
    state = AsyncValue<List<Reward>>.loading().copyWithPrevious(state);
    final result = await _rewardRepository.getShopByGiver(giverId, availableOnly: true);

    if (!mounted) return;

    switch (result) {
      case Success(data: final rewards):
        state = AsyncValue.data(rewards);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<Reward>> redeem(String rewardId) async {
    final result = await _rewardRepository.redeem(rewardId);

    if (!mounted) return result;

    if (result is Success<Reward>) {
      final current = state.valueOrNull;
      if (current != null) {
        // The server returns the reward with its new stock. Patch the shelf
        // locally instead of reloading the whole shop.
        final next = <Reward>[];
        for (final reward in current) {
          if (reward.id != result.data.id) {
            next.add(reward);
          } else if (result.data.stock > 0) {
            next.add(result.data);
          }
        }
        state = AsyncValue.data(next);
      }
    }
    return result;
  }
}
