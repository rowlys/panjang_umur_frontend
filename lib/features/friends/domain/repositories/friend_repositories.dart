import '../../../../core/utils/result.dart';

import '../models/friend.dart';

abstract class FriendRepository {
  Future<Result<List<Friend>>> getFriends();
  Future<Result<void>> addFriend(String friendId);
  Future<Result<void>> acceptFriendRequest(String friendId);
  Future<Result<void>> declineFriendRequest(String friendId);
  Future<Result<void>> removeFriend(String friendId);
  Future<Result<List<Friend>>> getFriendRequests();

  Future<Result<List<UserWithFriendStatus>>> searchUsers(String prefix, int limit);

}