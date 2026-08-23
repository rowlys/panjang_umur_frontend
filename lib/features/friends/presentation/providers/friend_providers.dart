import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/friend_repository.dart';

import '../../../../core/models/user.dart';
import '../../domain/models/friend.dart';
import '../../data/datasources/friend_remote_datasource.dart';
import '../../data/repositories/friend_repository_impl.dart';
import '../controllers/friend_controller.dart';
import '../controllers/friend_request_controller.dart';

final friendRemoteDataSourceProvider = Provider<FriendRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FriendRemoteDataSource(client: dioClient);
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final remoteDataSource = ref.watch(friendRemoteDataSourceProvider);
  return FriendRepositoryImpl(remoteDataSource);
});

final friendControllerProvider = StateNotifierProvider<FriendController, AsyncValue<List<User>>>((ref) {
  final friendRepository = ref.watch(friendRepositoryProvider);
  return FriendController(friendRepository);
});

final friendRequestControllerProvider = StateNotifierProvider<FriendRequestController, AsyncValue<(List<IncomingFriendRequest>, List<OutgoingFriendRequest>)>>((ref) {
  final friendRepository = ref.watch(friendRepositoryProvider);
  return FriendRequestController(friendRepository);
});