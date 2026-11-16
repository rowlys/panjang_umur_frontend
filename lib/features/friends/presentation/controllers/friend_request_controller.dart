import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../domain/models/auth.dart';
import '../../domain/models/friend.dart';
import '../../domain/repositories/friend_request_repository.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

// state = incoming requests, outgoing requests
class FriendRequestController extends StateNotifier<AsyncValue<(List<IncomingFriendRequest>, List<OutgoingFriendRequest>)>> {
  final FriendRequestRepository _friendRequestRepository;

  FriendRequestController(this._friendRequestRepository) : super(const AsyncValue.loading()) {
    getFriendRequests();
  }

  Future<void> getFriendRequests() async {
    state = AsyncValue<(List<IncomingFriendRequest>, List<OutgoingFriendRequest>)>.loading().copyWithPrevious(state);
    final result = await _friendRequestRepository.getFriendRequests();

    if (!mounted) return;

    switch (result) {
      case Success(data: final requests):
        state = AsyncValue.data(requests);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<void>> acceptFriendRequest(String requestId) async {
    final result = await _friendRequestRepository.acceptFriendRequest(requestId);
    if (result is Success<void>) {
      await getFriendRequests();
    }
    return result;
  }

  Future<Result<void>> declineFriendRequest(String requestId) async {
    final result = await _friendRequestRepository.declineFriendRequest(requestId);
    if (result is Success<void>) {
      await getFriendRequests();
    }
    return result;
  }

  /// Sends a request and refreshes the lists. Unlike accepting, this does not
  /// flip the whole page into a loading state, so the button can react itself.
  Future<Result<void>> sendFriendRequest(String userId) async {
    final result = await _friendRequestRepository.sendFriendRequest(userId);
    if (result is Success<void>) {
      await getFriendRequests();
    }
    return result;
  }
}