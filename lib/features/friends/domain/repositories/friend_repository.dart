import '../../../../core/utils/result.dart';

import '../../../../core/models/user.dart';
import '../models/friend.dart';

abstract class FriendRepository {
  Future<Result<List<User>>> getFriends();
  Future<Result<void>> addFriend(String userId);
  Future<Result<void>> acceptFriendRequest(String requestId);
  Future<Result<void>> declineFriendRequest(String requestId);
  Future<Result<void>> removeFriend(String friendId);
  Future<Result<(List<IncomingFriendRequest> incoming, List<OutgoingFriendRequest> outgoing)>> getFriendRequests();
}