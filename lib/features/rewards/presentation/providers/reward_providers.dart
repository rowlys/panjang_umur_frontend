import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/providers/core_providers.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/reward.dart';
import '../../domain/repositories/reward_repository.dart';
import '../../data/datasources/reward_remote_datasource.dart';
import '../../data/repositories/reward_repository_impl.dart';
import '../controllers/my_shop_controller.dart';
import '../controllers/friend_shop_controller.dart';
import '../controllers/reward_claims_controller.dart';

final rewardRemoteDataSourceProvider = Provider<RewardRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RewardRemoteDataSource(client: dioClient);
});

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  final rewardRemoteDataSource = ref.watch(rewardRemoteDataSourceProvider);
  return RewardRepositoryImpl(rewardRemoteDataSource);
});

final myShopControllerProvider = StateNotifierProvider.autoDispose<MyShopController, AsyncValue<List<Reward>>>((ref) {
  final rewardRepository = ref.watch(rewardRepositoryProvider);
  return MyShopController(rewardRepository);
});

final friendShopControllerProvider = StateNotifierProvider.autoDispose
    .family<FriendShopController, AsyncValue<List<Reward>>, String>((ref, giverId) {
  final rewardRepository = ref.watch(rewardRepositoryProvider);
  return FriendShopController(rewardRepository, giverId);
});

final rewardDetailProvider = FutureProvider.autoDispose.family<Reward, String>((ref, id) async {
  final repository = ref.watch(rewardRepositoryProvider);
  final result = await repository.getById(id);

  switch (result) {
    case Success(data: final reward):
      return reward;
    case Error(failure: final error):
      throw Exception(error.message);
  }
});

final rewardClaimsControllerProvider = StateNotifierProvider.autoDispose
    .family<RewardClaimsController, AsyncValue<RewardClaimsPage>, String>((ref, rewardId) {
  final rewardRepository = ref.watch(rewardRepositoryProvider);
  return RewardClaimsController(rewardRepository, rewardId);
});
