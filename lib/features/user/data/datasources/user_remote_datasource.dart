import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../../../core/models/user.dart';
import '../../domain/models/avatar_upload_slot.dart';

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

  Future<User> updateProfile(String name, String username, Gender? gender) async {
    final response = await _client.patch('/users/me', data: {
      'name': name,
      'username': username,
      'gender': ?gender?.index,
    });

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _client.patch('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<AvatarUploadSlot> getAvatarUploadUrl() async {
    final response = await _client.get('/users/me/avatar-upload-url');
    return AvatarUploadSlot.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateAvatar(String imageId) async {
    final response = await _client.patch('/users/me/avatar', data: {'imageId': imageId});
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> removeAvatar() async {
    final response = await _client.delete('/users/me/avatar');
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}