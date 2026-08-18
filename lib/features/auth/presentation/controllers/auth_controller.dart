import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/auth.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../../../../core/utils/result.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.loading()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.getMe();

    switch (result) {
      case Success(data: final user):
        state = AsyncValue.data(user);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> logIn(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.logIn(username, password);

    switch (result) {
      case Success(data: final session):
        state = AsyncValue.data(session.user);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.logOut();

    switch (result) {
      case Success(data: _):
        state = const AsyncValue.data(null);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }
}