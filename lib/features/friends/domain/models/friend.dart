import '../../../../core/models/user.dart';

class FriendRequest {
  final String id;
  final String requesterId;
  final String addresseeId;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      addresseeId: json['addresseeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'addresseeId': addresseeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}