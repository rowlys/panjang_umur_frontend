import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/features/rewards/domain/models/reward.dart';
import 'package:panjang_umur_frontend/features/rewards/domain/repositories/reward_repository.dart';
import '../datasources/reward_remote_datasource.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSource _rewardRemoteDataSource;

  RewardRepositoryImpl(this._rewardRemoteDataSource);

  @override
  Future<Result<Reward>> create({
    required String title,
    required String description,
    required int cost,
    required RewardVisibility visibility,
    required int stock,
    List<String> allowedUserIds = const [],
  }) async {
    try {
      final reward = await _rewardRemoteDataSource.create(
        title: title,
        description: description,
        cost: cost,
        visibility: visibility,
        stock: stock,
        allowedUserIds: allowedUserIds,
      );
      return Success(reward);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Reward>>> getMyShop({bool? availableOnly}) async {
    try {
      final rewards = await _rewardRemoteDataSource.getMyShop(availableOnly: availableOnly);
      return Success(rewards);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Reward>>> getShopByGiver(String giverId, {bool? availableOnly}) async {
    try {
      final rewards = await _rewardRemoteDataSource.getShopByGiver(giverId, availableOnly: availableOnly);
      return Success(rewards);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Reward>> redeem(String rewardId) async {
    try {
      final reward = await _rewardRemoteDataSource.redeem(rewardId);
      return Success(reward);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Reward>> getById(String rewardId) async {
    try {
      final reward = await _rewardRemoteDataSource.getById(rewardId);
      return Success(reward);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Reward>> updateStock(String rewardId, int stock) async {
    try {
      final reward = await _rewardRemoteDataSource.updateStock(rewardId, stock);
      return Success(reward);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<RewardClaim>>> getClaimsForReward(String rewardId, {DateTime? before, int? limit}) async {
    try {
      final claims = await _rewardRemoteDataSource.getClaimsForReward(rewardId, before: before, limit: limit);
      return Success(claims);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
