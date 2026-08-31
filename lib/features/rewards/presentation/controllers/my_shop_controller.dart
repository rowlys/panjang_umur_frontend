import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/reward.dart';
import '../../domain/repositories/reward_repository.dart';

class MyShopController extends StateNotifier<AsyncValue<List<Reward>>> {
  final RewardRepository _rewardRepository;

  MyShopController(this._rewardRepository) : super(const AsyncValue.loading()) {
    getMyShop();
  }

  Future<void> getMyShop() async {
    state = const AsyncValue.loading();
    final result = await _rewardRepository.getMyShop();

    switch (result) {
      case Success(data: final rewards):
        state = AsyncValue.data(rewards);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<Reward>> create({
    required String title,
    required String description,
    required int cost,
    required RewardVisibility visibility,
    required int stock,
    List<String> allowedUserIds = const [],
  }) async {
    final result = await _rewardRepository.create(
      title: title,
      description: description,
      cost: cost,
      visibility: visibility,
      stock: stock,
      allowedUserIds: allowedUserIds,
    );

    if (result is Success<Reward>) {
      await getMyShop();
    }
    return result;
  }

  Future<Result<Reward>> updateStock(String rewardId, int stock) async {
    final result = await _rewardRepository.updateStock(rewardId, stock);

    if (result is Success<Reward>) {
      await getMyShop();
    }
    return result;
  }
}
