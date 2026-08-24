import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../domain/models/friend.dart';

class FriendRequestRemoteDataSource {
  final DioClient _client;

  FriendRequestRemoteDataSource({required this._client});

  Future<void> sendFriendRequest(String userId) async {
    await _client.post('/friends/requests', queryParameters: {'userId': userId});
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _client.post('/friends/requests/$requestId/accept');
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _client.post('/friends/requests/$requestId/decline');
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