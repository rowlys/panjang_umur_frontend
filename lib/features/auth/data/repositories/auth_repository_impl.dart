import '../../../../core/utils/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

import '../../domain/models/auth.dart';
import '../../../../core/models/user.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<AuthSession>> logIn(String username, String password) async {
    try {
      final data = await _remoteDataSource.logIn(username, password);
      
      await _localDataSource.setToken(data.token);

      return Success(data);
    } on UnauthorizedException catch (e) {
      return Error(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> register(String name, String username, String password) async {
    try {
      final userID = await _remoteDataSource.register(name, username, password);

      return Success(userID);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getMe() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null) {
        return Success(null);
      }
      final user = await _remoteDataSource.getMe();
      return Success(user);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logOut() async {
    try {
      await _localDataSource.logOut();
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
    return Success(null);
  }

  @override
  Future<Result<bool>> isLoggedIn() async {
    try {
      final token = await _localDataSource.getToken();
      return Success(token != null);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }


}