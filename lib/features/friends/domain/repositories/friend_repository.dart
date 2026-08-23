import '../../../../core/utils/result.dart';

import '../../../../core/models/user.dart';
import '../models/friend.dart';

abstract class FriendRepository {
  Future<Result<List<User>>> getFriends();
  Future<Result<void>> addFriend(String userId);
  Future<Result<void>> removeFriend(String friendId);
}