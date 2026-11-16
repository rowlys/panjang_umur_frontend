import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../../../core/utils/result.dart';

class UserSearchController extends StateNotifier<AsyncValue<List<ForeignUser>>> {
  final UserRepository _userRepository;
  int _requestId = 0;

  UserSearchController(this._userRepository) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    // Usernames are shown as @name, so accept a pasted @name too.
    final normalized = query.trim().replaceFirst(RegExp(r'^@'), '');
    final requestId = ++_requestId;

    if (normalized.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = AsyncValue<List<ForeignUser>>.loading().copyWithPrevious(state);
    final result = await _userRepository.searchUsers(normalized);

    // A newer search started while this one was in flight. Dropping the stale
    // response keeps an older query from replacing current results.
    if (!mounted || requestId != _requestId) return;

    switch (result) {
      case Success(data: final users):
        state = AsyncValue.data(users);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  void clearSearch() {
    // Invalidate any request that is still in flight.
    _requestId++;
    state = const AsyncValue.data([]);
  }
}
