import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_remote_datasource.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource _friendRemoteDataSource;

  FriendRepositoryImpl(this._friendRemoteDataSource);

  @override
  Future<Result<List<User>>> getFriends() async {
    try {
      final friends = await _friendRemoteDataSource.getFriends();
      return Success(friends);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addFriend(String userId) async {
    try {
      await _friendRemoteDataSource.addFriend(userId);
      return Success(null);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFriend(String friendId) async {
    try {
      await _friendRemoteDataSource.removeFriend(friendId);
      return Success(null);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}