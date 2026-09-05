import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../models/conversation_summary.dart';
import '../models/message.dart';
import '../models/read_receipt.dart';

abstract class ChatRepository {
  Future<Result<List<Message>>> getMessages({
    required String friendId,
    DateTime? before,
    int? limit,
  });

  Future<Result<void>> markAsRead(String friendId);

  Future<Result<List<ConversationSummary>>> getConversations();

  Stream<Message> get incomingMessages;

  Stream<ReadReceipt> get incomingReadReceipts;

  void sendMessage(String friendId, String body);
}
