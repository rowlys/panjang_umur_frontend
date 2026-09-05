import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:panjang_umur_frontend/features/user/presentation/providers/user_providers.dart';

import '../../domain/models/message.dart';
import '../controllers/chat_room_controller.dart';
import '../providers/chat_providers.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String friendId;

  const ChatRoomScreen({super.key, required this.friendId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _handleSend() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    ref.read(chatRoomControllerProvider(widget.friendId).notifier).sendMessage(text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendAsync = ref.watch(userProfileControllerProvider(widget.friendId));
    final myUserId = ref.watch(authControllerProvider).valueOrNull?.id;
    final roomState = ref.watch(chatRoomControllerProvider(widget.friendId));

    ref.listen(chatRoomControllerProvider(widget.friendId), (previous, next) {
      final previousCount = previous?.valueOrNull?.messages.length ?? 0;
      final nextCount = next.valueOrNull?.messages.length ?? 0;
      if (nextCount > previousCount) _scrollToBottom();

      // Opening/using this room calls markAsRead behind the
      // scenes (see ChatRoomController)
      final justFinishedLoading = (previous?.isLoading ?? true) && !next.isLoading;
      
      // Invalidate the Friends list summaries so the unread 
      // badge doesn't linger stale markAsRead.
      if (justFinishedLoading || nextCount > previousCount) {
        ref.invalidate(conversationSummariesControllerProvider);
      }
    });

    final title = friendAsync.maybeWhen(
      data: (user) => user.name,
      orElse: () => 'Chat',
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: roomState.when(
              data: (page) => _MessageList(
                page: page,
                myUserId: myUserId,
                scrollController: _scrollController,
                onLoadMore: () =>
                    ref.read(chatRoomControllerProvider(widget.friendId).notifier).loadMore(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load chat:\n$error')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ChatRoomState page;
  final String? myUserId;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;

  const _MessageList({
    required this.page,
    required this.myUserId,
    required this.scrollController,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (page.messages.isEmpty) {
      return const Center(child: Text('No messages yet. Say hi!'));
    }

    final lastMineIndex = page.messages.lastIndexWhere(
      (message) => message.senderId == myUserId,
    );

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: page.messages.length + (page.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (page.hasMore && index == 0) {
          return Center(
            child: page.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: onLoadMore,
                    child: const Text('Load earlier messages'),
                  ),
          );
        }

        final messageIndex = index - (page.hasMore ? 1 : 0);
        final message = page.messages[messageIndex];
        final isMine = message.senderId == myUserId;
        return _MessageBubble(
          message: message,
          isMine: isMine,
          // Only the last message sent shows a status label
          showStatus: isMine && messageIndex == lastMineIndex,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final bool showStatus;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMine ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message.body,
                style: TextStyle(
                  color: isMine ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (showStatus)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  message.readAt != null ? 'Read' : 'Sent',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
