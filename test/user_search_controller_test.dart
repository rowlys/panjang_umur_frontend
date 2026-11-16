import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/user/domain/repositories/user_repositories.dart';
import 'package:panjang_umur_frontend/features/user/presentation/controllers/user_search_controller.dart';

class _FakeUserRepository implements UserRepository {
  final pending = <String, Completer<Result<List<ForeignUser>>>>{};
  final queries = <String>[];

  @override
  Future<Result<List<ForeignUser>>> searchUsers(String query) {
    queries.add(query);
    final completer = Completer<Result<List<ForeignUser>>>();
    pending[query] = completer;
    return completer.future;
  }

  @override
  Future<Result<User>> getUserById(String userId) => throw UnimplementedError();

  @override
  Future<Result<User>> updateProfile(String name, String username, Gender? gender) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> changePassword(String currentPassword, String newPassword) =>
      throw UnimplementedError();

  @override
  Future<Result<User>> uploadAvatar(Uint8List bytes) => throw UnimplementedError();

  @override
  Future<Result<User>> removeAvatar() => throw UnimplementedError();
}

ForeignUser _user(String username) {
  return ForeignUser(
    id: 'id-$username',
    name: username,
    username: username,
    friendStatus: FriendRelation.none,
  );
}

void main() {
  test('a slow earlier search cannot overwrite a newer result', () async {
    final repository = _FakeUserRepository();
    final controller = UserSearchController(repository);

    final first = controller.searchUsers('ba');
    final second = controller.searchUsers('basten');

    repository.pending['basten']!.complete(Success([_user('basten')]));
    await second;

    repository.pending['ba']!.complete(Success(<ForeignUser>[]));
    await first;

    expect(controller.state.value!.map((user) => user.username), ['basten']);
  });

  test('clearing the search ignores a response that is still in flight', () async {
    final repository = _FakeUserRepository();
    final controller = UserSearchController(repository);

    final pending = controller.searchUsers('basten');
    controller.clearSearch();

    repository.pending['basten']!.complete(Success([_user('basten')]));
    await pending;

    expect(controller.state.value, isEmpty);
  });

  test('accepts a pasted @username and trims spaces', () async {
    final repository = _FakeUserRepository();
    final controller = UserSearchController(repository);

    final pending = controller.searchUsers('  @Basten ');
    expect(repository.queries.last, 'Basten');

    repository.pending['Basten']!.complete(Success(<ForeignUser>[]));
    await pending;
  });
}
