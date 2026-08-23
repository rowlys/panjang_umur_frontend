import 'package:panjang_umur_frontend/core/network/dio_client.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';

import '../../domain/models/friend.dart';

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

  Future<void> acceptFriendRequest(String requestId) async {
    await _client.post('/friends/requests/$requestId/accept');
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _client.post('/friends/requests/$requestId/decline');
  }

  Future<void> removeFriend(String friendId) async {
    await _client.delete('/friends/$friendId');
  }

  Future<(List<IncomingFriendRequest> incoming, List<OutgoingFriendRequest> outgoing)> getFriendRequests() async {
    final response = await _client.get('/friends/requests');

    final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    final List<dynamic> rawIncoming = responseData['incoming'] as List<dynamic>;
    final List<dynamic> rawOutgoing = responseData['outgoing'] as List<dynamic>;

    final List<IncomingFriendRequest> incomingRequests = rawIncoming.map((json) => IncomingFriendRequest.fromJson(json)).toList();
    final List<OutgoingFriendRequest> outgoingRequests = rawOutgoing.map((json) => OutgoingFriendRequest.fromJson(json)).toList();

    return (incomingRequests, outgoingRequests);
  }
}