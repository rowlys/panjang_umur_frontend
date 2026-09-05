import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/providers/core_providers.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';

import '../../domain/repositories/chat_repository.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/chat_socket_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/conversation_summary.dart';
import '../controllers/chat_room_controller.dart';
import '../controllers/conversation_summaries_controller.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRemoteDataSource(client: dioClient);
});

final chatSocketProvider = Provider<ChatSocketDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final socket = ChatSocketDataSource(client: dioClient);

  ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
    final user = next.valueOrNull;
    if (user != null) {
      socket.connect();
    } else if (!next.isLoading) {
      socket.disconnect();
    }
  }, fireImmediately: true);

  ref.onDispose(socket.dispose);

  return socket;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final chatRemoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  final chatSocket = ref.watch(chatSocketProvider);
  return ChatRepositoryImpl(chatRemoteDataSource, chatSocket);
});

final chatRoomControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatRoomController, AsyncValue<ChatRoomState>, String>((
      ref,
      friendId,
    ) {
      final chatRepository = ref.watch(chatRepositoryProvider);
      return ChatRoomController(chatRepository, friendId);
    });

final conversationSummariesControllerProvider = StateNotifierProvider
    .autoDispose<
      ConversationSummariesController,
      AsyncValue<List<ConversationSummary>>
    >((ref) {
      final chatRepository = ref.watch(chatRepositoryProvider);
      return ConversationSummariesController(chatRepository);
    });
