import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import '../../domain/models/friend.dart';
import '../../domain/repositories/friend_request_repository.dart';
import '../datasources/friend_request_remote_datasource.dart';

class FriendRequestRepositoryImpl implements FriendRequestRepository {  
  final FriendRequestRemoteDataSource _friendRequestRemoteDataSource;

  FriendRequestRepositoryImpl(this._friendRequestRemoteDataSource);

  @override
  Future<Result<void>> sendFriendRequest(String userId) async {
    try {
      await _friendRequestRemoteDataSource.sendFriendRequest(userId);
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
      await _friendRequestRemoteDataSource.acceptFriendRequest(requestId);
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
      await _friendRequestRemoteDataSource.declineFriendRequest(requestId);
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
      final (incoming, outgoing) = await _friendRequestRemoteDataSource.getFriendRequests();
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