import '../../../../core/models/user.dart';

class IncomingFriendRequest {
  final String id;
  final User requester;
  final DateTime createdAt;

  IncomingFriendRequest({
    required this.id,
    required this.requester,
    required this.createdAt,
  });

  factory IncomingFriendRequest.fromJson(Map<String, dynamic> json) {
    return IncomingFriendRequest(
      id: json['id'] as String,
      requester: User.fromJson(json['requester'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester': requester.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OutgoingFriendRequest {
  final String id;
  final User addressee;
  final DateTime createdAt;

  OutgoingFriendRequest({
    required this.id,
    required this.addressee,
    required this.createdAt,
  });

  factory OutgoingFriendRequest.fromJson(Map<String, dynamic> json) {
    return OutgoingFriendRequest(
      id: json['id'] as String,
      addressee: User.fromJson(json['addressee'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressee': addressee.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}