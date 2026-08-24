import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';

class FriendRemoteDataSource {
  final DioClient _client;

  FriendRemoteDataSource({required this._client});

  Future<List<User>> getFriends() async {
    final response = await _client.get('/friends');
    final List<dynamic> data = response.data;
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<void> addFriend(String userId) async {
    await _client.post('/friends/requests', data: {'userId': userId});
  }

  Future<void> removeFriend(String friendId) async {
    await _client.delete('/friends/$friendId');
  }
}