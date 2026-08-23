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
    state = const AsyncValue.loading();
    final result = await _friendRequestRepository.getFriendRequests();

    switch (result) {
      case Success(data: final requests):
        state = AsyncValue.data(requests);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    state = const AsyncValue.loading();
    final result = await _friendRequestRepository.acceptFriendRequest(requestId);

    switch (result) {
      case Success(data: _):
        await getFriendRequests();
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    state = const AsyncValue.loading();
    final result = await _friendRequestRepository.declineFriendRequest(requestId);

    switch (result) {
      case Success(data: _):
        await getFriendRequests();
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    state = const AsyncValue.loading();
    final result = await _friendRequestRepository.sendFriendRequest(userId);

    switch (result) {
      case Success(data: _):
        await getFriendRequests();
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }
}