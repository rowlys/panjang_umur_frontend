import '../../../../core/utils/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/models/user.dart';
import '../../domain/repositories/user_repositories.dart';
// import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  // final UserLocalDataSource _localDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<User>> getUserById(String userId) async {
    try {
      final user = await _remoteDataSource.getUserById(userId);
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
  Future<Result<List<ForeignUser>>> searchUsers(String query, {int limit = 10}) async {
    try {
      final users = await _remoteDataSource.searchUsers(query, limit);
      return Success(users);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}