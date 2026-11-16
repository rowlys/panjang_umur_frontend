import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/models/user.dart';
import '../../domain/repositories/user_repositories.dart';
// import '../datasources/user_local_datasource.dart';
import '../datasources/avatar_upload_datasource.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final AvatarUploadDataSource _avatarUploadDataSource;
  // final UserLocalDataSource _localDataSource;

  UserRepositoryImpl(this._remoteDataSource, this._avatarUploadDataSource);

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

  @override
  Future<Result<User>> updateProfile(String name, String username, Gender? gender) async {
    try {
      final user = await _remoteDataSource.updateProfile(name, username, gender);
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
  Future<Result<void>> changePassword(String currentPassword, String newPassword) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      return Success(null);
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
  Future<Result<User>> uploadAvatar(Uint8List bytes) async {
    try {
      final slot = await _remoteDataSource.getAvatarUploadUrl();
      await _avatarUploadDataSource.upload(uploadUrl: slot.uploadUrl, bytes: bytes);
      final user = await _remoteDataSource.updateAvatar(slot.imageId);
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
  Future<Result<User>> removeAvatar() async {
    try {
      final user = await _remoteDataSource.removeAvatar();
      return Success(user);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}