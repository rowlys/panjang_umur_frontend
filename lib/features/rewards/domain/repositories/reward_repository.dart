import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/rewards/domain/models/reward.dart';

abstract class RewardRepository {
  Future<Result<Reward>> create({
    required String title,
    required String description,
    required int cost,
    required RewardVisibility visibility,
    required int stock,
    List<String> allowedUserIds,
  });

  Future<Result<List<Reward>>> getMyShop({bool? availableOnly});
  Future<Result<List<Reward>>> getShopByGiver(String giverId, {bool? availableOnly});
  Future<Result<Reward>> redeem(String rewardId);
  Future<Result<Reward>> getById(String rewardId);
  Future<Result<Reward>> updateStock(String rewardId, int stock);
  Future<Result<List<RewardClaim>>> getClaimsForReward(String rewardId, {DateTime? before, int? limit});
}
