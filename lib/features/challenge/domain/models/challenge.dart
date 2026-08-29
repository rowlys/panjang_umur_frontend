enum ChallengeType { bounty, daily, weekly }
enum ChallengeStatus { active, expired, cancelled, completed }

class Challenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final ChallengeType type;
  final ChallengeStatus status;
  final int resetDay;
  final String creatorId;
  final bool restricted;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.type,
    required this.status,
    required this.resetDay,
    required this.creatorId,
    required this.restricted,
    required this.createdAt,
    this.expiresAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      points: json['points'] as int,
      type: parseChallengeType(json['type'] as int),
      status: parseChallengeStatus(json['status'] as int),
      resetDay: json['resetDay'] as int,
      creatorId: json['creatorId'] as String,
      restricted: json['restricted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'type': type.index,
      'status': status.index,
      'resetDay': resetDay,
      'creatorId': creatorId,
      'restricted': restricted,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

}

ChallengeStatus parseChallengeStatus(int status) {
  switch (status) {
    case 0:
      return ChallengeStatus.active;
    case 1:
      return ChallengeStatus.expired;
    case 2:
      return ChallengeStatus.cancelled;
    case 3:
      return ChallengeStatus.completed;
    default:
      throw ArgumentError('Invalid challenge status: $status');
  }
}

ChallengeType parseChallengeType(int type) {
  switch (type) {
    case 0:
      return ChallengeType.bounty;
    case 1:
      return ChallengeType.daily;
    case 2:
      return ChallengeType.weekly;
    default:
      throw ArgumentError('Invalid challenge type: $type');
  }
}
