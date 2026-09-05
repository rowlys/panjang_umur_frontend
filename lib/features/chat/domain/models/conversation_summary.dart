import 'message.dart';

class ConversationSummary {
  final String friendId;
  final Message lastMessage;
  final int unreadCount;

  ConversationSummary({
    required this.friendId,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      friendId: json['friendId'] as String,
      lastMessage: Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: json['unreadCount'] as int,
    );
  }
}
