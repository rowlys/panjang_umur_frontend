import '../../../../core/utils/result.dart';
import '../../../../core/models/user.dart';

abstract class UserRepository {
  Future<Result<User>> getUserById(String userId);
  Future<Result<List<ForeignUser>>> searchUsers(String query);
}