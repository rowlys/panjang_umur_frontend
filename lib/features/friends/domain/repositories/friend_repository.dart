import '../../../../core/utils/result.dart';

import '../../../../core/models/user.dart';

abstract class FriendRepository {
  Future<Result<List<User>>> getFriends();
  Future<Result<void>> removeFriend(String friendId);
}