import '../../../../core/utils/result.dart';

import '../models/auth.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> logIn(String username, String password);
  Future<Result<String>> register(String name, String username, String password);
  Future<Result<void>> logOut();
  Future<Result<bool>> isLoggedIn();
  Future<Result<User?>> getMe();
}

