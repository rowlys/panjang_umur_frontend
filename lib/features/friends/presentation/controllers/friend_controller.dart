import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../domain/models/auth.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';
import '../../domain/repositories/friend_repository.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

class FriendController extends StateNotifier<AsyncValue<List<User>>> {
  final FriendRepository _friendRepository;

  FriendController(this._friendRepository) : super(const AsyncValue.loading()) {
    getFriends();
  }

  Future<void> getFriends() async {
    state = AsyncValue<List<User>>.loading().copyWithPrevious(state);
    final result = await _friendRepository.getFriends();

    if (!mounted) return;

    switch (result) {
      case Success(data: final friends):
        state = AsyncValue.data(friends);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<void>> removeFriend(String friendId) async {
    final result = await _friendRepository.removeFriend(friendId);
    if (result is Success) await getFriends();
    return result;
  }
}