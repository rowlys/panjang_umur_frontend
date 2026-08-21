class User {
  final String id;
  final String name;
  final String username;

  User({
    required this.id,
    required this.name,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

class ForeignUser {
  final String id;
  final String? name;
  final String username;
  final int friendStatus;

  ForeignUser({
    required this.id,
    this.name,
    required this.username,
    required this.friendStatus,
  });

  factory ForeignUser.fromJson(Map<String, dynamic> json) {
    return ForeignUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String,
      friendStatus: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'status': friendStatus,
    };
  }
}