import '../../../../core/utils/result.dart';

import '../../../../core/models/user.dart';
import '../models/friend.dart';

abstract class FriendRequestRepository {
  Future<Result<void>> sendFriendRequest(String userId);
  Future<Result<void>> acceptFriendRequest(String requestId);
  Future<Result<void>> declineFriendRequest(String requestId);
  Future<Result<(List<IncomingFriendRequest> incoming, List<OutgoingFriendRequest> outgoing)>> getFriendRequests();
}