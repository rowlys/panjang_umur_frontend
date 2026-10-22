enum Gender { unspecified, male, female }

class User {
  final String id;
  final String name;
  final String username;
  final Gender gender;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.gender = Gender.unspecified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      gender: Gender.values.elementAtOrNull(json['gender'] as int? ?? 0) ?? Gender.unspecified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'gender': gender.index,
    };
  }
}

enum FriendRelation { none, pending, friends }

class ForeignUser {
  final String id;
  final String? name;
  final String username;
  final FriendRelation friendStatus;

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
      friendStatus: _parseFriendStatus(json['status'] as int),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'status': friendStatus.index,
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