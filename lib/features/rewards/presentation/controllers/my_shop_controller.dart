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
    state = AsyncValue<List<Reward>>.loading().copyWithPrevious(state);
    final result = await _rewardRepository.getMyShop();

    if (!mounted) return;

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
      _upsert(result.data);
    }
    return result;
  }

  Future<Result<Reward>> update(
    String rewardId, {
    String? title,
    String? description,
    int? cost,
    int? stock,
    RewardVisibility? visibility,
    List<String>? allowedUserIds,
  }) async {
    final result = await _rewardRepository.update(
      rewardId,
      title: title,
      description: description,
      cost: cost,
      stock: stock,
      visibility: visibility,
      allowedUserIds: allowedUserIds,
    );

    if (result is Success<Reward>) {
      _upsert(result.data);
    }
    return result;
  }

  /// Replaces the reward in place, or adds it when it is new. Keeps the list on
  /// screen instead of reloading it.
  void _upsert(Reward reward) {
    if (!mounted) return;
    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.indexWhere((entry) => entry.id == reward.id);
    if (index == -1) {
      state = AsyncValue.data([reward, ...current]);
      return;
    }

    final next = [...current];
    next[index] = reward;
    state = AsyncValue.data(next);
  }
}
