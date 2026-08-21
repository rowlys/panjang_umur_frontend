class Friend {
  final String id;
  final String name;
  final String username;

  Friend({
    required this.id,
    required this.name,
    required this.username,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
    };
  }
}

class UserWithFriendStatus {
  final String id;
  final String name;
  final String username;
  final int status;

  UserWithFriendStatus({
    required this.id,
    required this.name,
    required this.username,
    required this.status,
  });

  factory UserWithFriendStatus.fromJson(Map<String, dynamic> json) {
    return UserWithFriendStatus(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'status': status,
    };
  }
}