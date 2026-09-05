import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';

import '../../domain/models/message.dart';
import '../../domain/models/read_receipt.dart';
import '../../domain/repositories/chat_repository.dart';

const _messagePageSize = 30;

class ChatRoomState {
  final List<Message> messages;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatRoomState({
    required this.messages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ChatRoomState copyWith({
    List<Message>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ChatRoomController extends StateNotifier<AsyncValue<ChatRoomState>> {
  final ChatRepository _chatRepository;
  final String _friendId;

  StreamSubscription<Message>? _socketSubscription;
  StreamSubscription<ReadReceipt>? _readReceiptSubscription;

  ChatRoomController(this._chatRepository, this._friendId)
    : super(const AsyncValue.loading()) {
    _loadInitial();
    _socketSubscription = _chatRepository.incomingMessages.listen(
      _onMessageReceived,
    );
    _readReceiptSubscription = _chatRepository.incomingReadReceipts.listen(
      _onReadReceiptReceived,
    );
  }

  void _onMessageReceived(Message message) {
    final isForThisRoom =
        message.senderId == _friendId || message.recipientId == _friendId;
    if (!isForThisRoom) return;

    final page = state.valueOrNull;
    if (page == null) return;

    state = AsyncValue.data(
      page.copyWith(messages: [...page.messages, message]),
    );

    if (message.senderId == _friendId) {
      _chatRepository.markAsRead(_friendId);
    }
  }

  void _onReadReceiptReceived(ReadReceipt receipt) {
    if (receipt.friendId != _friendId) return;

    final page = state.valueOrNull;
    if (page == null) return;

    final messages = List<Message>.of(page.messages);
    var didPatch = false;

    // Go through newest-to-oldest while marking them as read and 
    // stop at the first already-read message of logged in user.
    for (var i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.senderId == _friendId) continue;
      if (message.readAt != null) break;

      if (!message.createdAt.isAfter(receipt.readAt)) {
        messages[i] = message.copyWith(readAt: receipt.readAt);
        didPatch = true;
      }
    }

    if (!didPatch) return;
    state = AsyncValue.data(page.copyWith(messages: messages));
  }

  Future<void> _loadInitial() async {
    final result = await _chatRepository.getMessages(
      friendId: _friendId,
      limit: _messagePageSize,
    );

    switch (result) {
      case Success(data: final messages):
        state = AsyncValue.data(
          ChatRoomState(
            messages: messages,
            hasMore: messages.length == _messagePageSize,
          ),
        );
        await _chatRepository.markAsRead(_friendId);
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<void> loadMore() async {
    final page = state.valueOrNull;
    if (page == null ||
        page.isLoadingMore ||
        !page.hasMore ||
        page.messages.isEmpty) {
      return;
    }

    state = AsyncValue.data(page.copyWith(isLoadingMore: true));

    final result = await _chatRepository.getMessages(
      friendId: _friendId,
      before: page.messages.first.createdAt,
      limit: _messagePageSize,
    );

    switch (result) {
      case Success(data: final older):
        state = AsyncValue.data(
          page.copyWith(
            messages: [...older, ...page.messages],
            hasMore: older.length == _messagePageSize,
            isLoadingMore: false,
          ),
        );
      case Error():
        state = AsyncValue.data(page.copyWith(isLoadingMore: false));
    }
  }

  void sendMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;
    _chatRepository.sendMessage(_friendId, trimmed);
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    super.dispose();
  }
}
