import '../../../../core/models/user.dart';

class FriendRequest {
  final String id;
  final User sender;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}