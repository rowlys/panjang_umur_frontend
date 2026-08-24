import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/repositories/friend_request_repository.dart';

import '../../../../core/models/user.dart';
import '../../domain/models/friend.dart';
import '../../data/datasources/friend_remote_datasource.dart';
import '../../data/datasources/friend_request_remote_datasource.dart';
import '../../data/repositories/friend_repository_impl.dart';
import '../../data/repositories/friend_request_repository_impl.dart';
import '../controllers/friend_controller.dart';
import '../controllers/friend_request_controller.dart';

final friendRemoteDataSourceProvider = Provider<FriendRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FriendRemoteDataSource(client: dioClient);
});

final friendRequestRemoteDataSourceProvider = Provider<FriendRequestRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FriendRequestRemoteDataSource(client: dioClient);
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final friendRemoteDataSource = ref.watch(friendRemoteDataSourceProvider);
  return FriendRepositoryImpl(friendRemoteDataSource);
});

final friendRequestRepositoryProvider = Provider<FriendRequestRepository>((ref) {
  final friendRequestRemoteDataSource = ref.watch(friendRequestRemoteDataSourceProvider);
  return FriendRequestRepositoryImpl(friendRequestRemoteDataSource);
});

final friendControllerProvider = StateNotifierProvider.autoDispose<FriendController, AsyncValue<List<User>>>((ref) {
  final friendRepository = ref.watch(friendRepositoryProvider);
  return FriendController(friendRepository);
});

final friendRequestControllerProvider = StateNotifierProvider.autoDispose<FriendRequestController, AsyncValue<(List<IncomingFriendRequest>, List<OutgoingFriendRequest>)>>((ref) {
  final friendRequestRepository = ref.watch(friendRequestRepositoryProvider);
  return FriendRequestController(friendRequestRepository);
});