import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/features/rewards/domain/models/reward.dart';

class RewardRemoteDataSource {
  final DioClient _client;

  RewardRemoteDataSource({required this._client});

  Future<Reward> create({
    required String title,
    required String description,
    required int cost,
    required RewardVisibility visibility,
    required int stock,
    List<String> allowedUserIds = const [],
  }) async {
    final response = await _client.post('/rewards', data: {
      'title': title,
      'description': description,
      'cost': cost,
      'visibility': visibility.index,
      'stock': stock,
      'allowedUserIds': allowedUserIds,
    });
    return Reward.fromJson(response.data);
  }

  Future<List<Reward>> getMyShop({bool? availableOnly}) async {
    final response = await _client.get('/rewards/shop/me', queryParameters: {
      'available': ?availableOnly?.toString(),
    });
    final List<dynamic> data = response.data;
    return data.map((json) => Reward.fromJson(json)).toList();
  }

  Future<List<Reward>> getShopByGiver(String giverId, {bool? availableOnly}) async {
    final response = await _client.get('/rewards/shop/$giverId', queryParameters: {
      'available': ?availableOnly?.toString(),
    });
    final List<dynamic> data = response.data;
    return data.map((json) => Reward.fromJson(json)).toList();
  }

  Future<Reward> redeem(String rewardId) async {
    final response = await _client.patch('/rewards/$rewardId/redeem');
    return Reward.fromJson(response.data);
  }

  Future<Reward> getById(String rewardId) async {
    final response = await _client.get('/rewards/$rewardId');
    return Reward.fromJson(response.data);
  }

  Future<Reward> updateStock(String rewardId, int stock) async {
    final response = await _client.patch('/rewards/$rewardId/stock', data: {'stock': stock});
    return Reward.fromJson(response.data);
  }

  Future<List<RewardClaim>> getClaimsGiven({String? rewardId, DateTime? before, int? limit}) async {
    final response = await _client.get('/rewards/claims/given', queryParameters: {
      'rewardId': ?rewardId,
      'before': ?before?.toUtc().toIso8601String(),
      'limit': ?limit?.toString(),
    });
    final List<dynamic> data = response.data;
    return data.map((json) => RewardClaim.fromJson(json)).toList();
  }

  Future<List<RewardClaim>> getClaimsRedeemed({String? giverId, DateTime? before, int? limit}) async {
    final response = await _client.get('/rewards/claims/redeemed', queryParameters: {
      'giverId': ?giverId,
      'before': ?before?.toUtc().toIso8601String(),
      'limit': ?limit?.toString(),
    });
    final List<dynamic> data = response.data;
    return data.map((json) => RewardClaim.fromJson(json)).toList();
  }

  Future<void> fulfillClaim(String claimId) async {
    await _client.patch('/rewards/claims/$claimId/fulfill');
  }

  Future<void> requestRefund(String claimId, String reason) async {
    await _client.patch('/rewards/claims/$claimId/refund/request', queryParameters: {'reason': reason});
  }

  Future<void> approveRefund(String claimId) async {
    await _client.patch('/rewards/claims/$claimId/refund/approve');
  }
}
