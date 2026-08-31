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
    state = const AsyncValue.loading();
    final result = await _rewardRepository.getShopByGiver(giverId, availableOnly: true);

    switch (result) {
      case Success(data: final rewards):
        state = AsyncValue.data(rewards);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<Reward>> redeem(String rewardId) async {
    final result = await _rewardRepository.redeem(rewardId);

    if (result is Success<Reward>) {
      await getShop();
    }
    return result;
  }
}
