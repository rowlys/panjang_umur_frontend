import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/core/error/exceptions.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';

import 'package:panjang_umur_frontend/features/chat/domain/models/conversation_summary.dart';
import 'package:panjang_umur_frontend/features/chat/domain/models/message.dart';
import 'package:panjang_umur_frontend/features/chat/domain/models/read_receipt.dart';
import 'package:panjang_umur_frontend/features/chat/domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_socket_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _chatRemoteDataSource;
  final ChatSocketDataSource _chatSocketDataSource;

  ChatRepositoryImpl(this._chatRemoteDataSource, this._chatSocketDataSource);

  @override
  Stream<Message> get incomingMessages => _chatSocketDataSource.messages;

  @override
  Stream<ReadReceipt> get incomingReadReceipts => _chatSocketDataSource.readReceipts;

  @override
  void sendMessage(String friendId, String body) {
    _chatSocketDataSource.send(friendId, body);
  }

  @override
  Future<Result<List<Message>>> getMessages({
    required String friendId,
    DateTime? before,
    int? limit,
  }) async {
    try {
      final messages = await _chatRemoteDataSource.getMessages(
        friendId: friendId,
        before: before,
        limit: limit,
      );
      return Success(messages);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(String friendId) async {
    try {
      await _chatRemoteDataSource.markAsRead(friendId);
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
  Future<Result<List<ConversationSummary>>> getConversations() async {
    try {
      final summaries = await _chatRemoteDataSource.getConversations();
      return Success(summaries);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
