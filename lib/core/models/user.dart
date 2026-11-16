enum Gender { unspecified, male, female }

String? _avatarUrlFromJson(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return value;
}

class User {
  final String id;
  final String name;
  final String username;
  final Gender gender;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.gender = Gender.unspecified,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      gender: Gender.values.elementAtOrNull(json['gender'] as int? ?? 0) ?? Gender.unspecified,
      avatarUrl: _avatarUrlFromJson(json['avatarUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'gender': gender.index,
      'avatarUrl': avatarUrl,
    };
  }
}

enum FriendRelation { none, pending, friends }

class ForeignUser {
  final String id;
  final String? name;
  final String username;
  final FriendRelation friendStatus;
  final String? avatarUrl;

  ForeignUser({
    required this.id,
    this.name,
    required this.username,
    required this.friendStatus,
    this.avatarUrl,
  });

  factory ForeignUser.fromJson(Map<String, dynamic> json) {
    return ForeignUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String,
      friendStatus: _parseFriendStatus(json['status'] as int),
      avatarUrl: _avatarUrlFromJson(json['avatarUrl']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'status': friendStatus.index,
      'avatarUrl': avatarUrl,
    };
  }

  static FriendRelation _parseFriendStatus(int status) {
    switch (status) {
      case 0:
        return FriendRelation.none;
      case 1:
        return FriendRelation.pending;
      case 2:
        return FriendRelation.friends;
      default:
        throw ArgumentError('Unknown friend status: $status');
    }
  }


}
