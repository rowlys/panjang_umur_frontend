import 'package:panjang_umur_frontend/core/models/user.dart';

import 'challenge.dart';
import 'challenge_submission.dart';

class ChallengeDetail {
  final String id;
  final String title;
  final String description;
  final int points;
  final ChallengeStatus status;
  final ChallengeType type;
  final int resetDay;
  final bool restricted;
  final User creator;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final SubmissionStatus? mySubmissionStatus;

  ChallengeDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
    required this.type,
    required this.resetDay,
    required this.restricted,
    required this.creator,
    required this.createdAt,
    this.expiresAt,
    this.mySubmissionStatus,
  });

  factory ChallengeDetail.fromJson(Map<String, dynamic> json) {
    return ChallengeDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      points: json['points'] as int,
      status: parseChallengeStatus(json['status'] as int),
      type: parseChallengeType(json['type'] as int),
      resetDay: json['resetDay'] as int,
      restricted: json['restricted'] as bool,
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      mySubmissionStatus: json['mySubmissionStatus'] != null
          ? parseSubmissionStatus(json['mySubmissionStatus'] as int)
          : null,
    );
  }
}
