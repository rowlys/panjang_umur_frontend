import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../../../core/models/user.dart';

class UserRemoteDataSource {
  final DioClient _client;

  UserRemoteDataSource(this._client);

  Future<User> getUserById(String userId) async {
    final response = await _client.get('/users/$userId');

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ForeignUser>> searchUsers(String prefix, int limit) async {
    final response = await _client.get('/users/search', queryParameters: {
      'prefix': prefix,
      'limit': limit,
    });

    final usersJson = response.data as List<dynamic>;
    return usersJson.map((json) => ForeignUser.fromJson(json as Map<String, dynamic>)).toList();
  }
}