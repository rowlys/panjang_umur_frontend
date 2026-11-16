import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../../../../core/models/user.dart';

abstract class UserRepository {
  Future<Result<User>> getUserById(String userId);
  Future<Result<List<ForeignUser>>> searchUsers(String query);
  Future<Result<User>> updateProfile(String name, String username, Gender? gender);
  Future<Result<void>> changePassword(String currentPassword, String newPassword);
  /// Uploads a square JPEG and makes it the user's profile picture.
  Future<Result<User>> uploadAvatar(Uint8List bytes);
  Future<Result<User>> removeAvatar();
}