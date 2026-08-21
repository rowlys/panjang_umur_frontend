import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user.dart';
import '../../domain/repositories/user_repositories.dart';
import '../../../../core/utils/result.dart';

class UserSearchController extends StateNotifier<AsyncValue<List<ForeignUser>>> {
  final UserRepository _userRepository;

  UserSearchController(this._userRepository) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    final result = await _userRepository.searchUsers(query);

    switch (result) {
      case Success(data: final users):
        state = AsyncValue.data(users);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}