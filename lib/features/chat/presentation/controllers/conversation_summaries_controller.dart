import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/conversation_summary.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/chat_repository.dart';

class ConversationSummariesController
    extends StateNotifier<AsyncValue<List<ConversationSummary>>> {
  final ChatRepository _chatRepository;

  StreamSubscription<Message>? _socketSubscription;

  ConversationSummariesController(this._chatRepository)
    : super(const AsyncValue.loading()) {
    refresh();
    // Any incoming message triggers a full refetch rather than
    // a local patch to unreadCount.
    _socketSubscription = _chatRepository.incomingMessages.listen((_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    final result = await _chatRepository.getConversations();

    switch (result) {
      case Success(data: final summaries):
        state = AsyncValue.data(summaries);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
}
