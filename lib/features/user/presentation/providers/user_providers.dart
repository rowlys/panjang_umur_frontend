import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repositories.dart';
import '../controllers/user_search_controller.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserRemoteDataSource(dioClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

final userSearchControllerProvider = StateNotifierProvider.autoDispose<UserSearchController, AsyncValue<List<ForeignUser>>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserSearchController(userRepository);
});

final userProfileControllerProvider = FutureProvider.family<User, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  
  final result = await repository.getUserById(userId);
  
  switch (result) {
    case Success(data: final user):
      return user;
    case Error(failure: final error):
      throw Exception(error.message); 
  }
});