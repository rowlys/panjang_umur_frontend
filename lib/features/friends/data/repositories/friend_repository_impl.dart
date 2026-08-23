import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import '../../domain/models/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_remote_datasource.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource _remoteDataSource;

  FriendRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<User>>> getFriends() async {
    try {
      final friends = await _remoteDataSource.getFriends();
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
      await _remoteDataSource.addFriend(userId);
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
  Future<Result<void>> acceptFriendRequest(String requestId) async {
    try {
      await _remoteDataSource.acceptFriendRequest(requestId);
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
  Future<Result<void>> declineFriendRequest(String requestId) async {
    try {
      await _remoteDataSource.declineFriendRequest(requestId);
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
      await _remoteDataSource.removeFriend(friendId);
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
  Future<Result<(List<IncomingFriendRequest>, List<OutgoingFriendRequest>)>> getFriendRequests() async {
    try {
      final (incoming, outgoing) = await _remoteDataSource.getFriendRequests();
      return Success((incoming, outgoing));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}