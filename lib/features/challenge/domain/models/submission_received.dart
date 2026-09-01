import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';

/// A submission made on a challenge I created (I'm the reviewer).
class SubmissionReceived {
  final String id;
  final String challengeId;
  final String challengeTitle;
  final int challengePoints;
  final ChallengeType challengeType;
  final ChallengeStatus challengeStatus;
  final String userId;
  final User user;
  final String? proofUrl;
  final DateTime periodStart;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? approvedAt;

  SubmissionReceived({
    required this.id,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengePoints,
    required this.challengeType,
    required this.challengeStatus,
    required this.userId,
    required this.user,
    this.proofUrl,
    required this.periodStart,
    required this.status,
    required this.submittedAt,
    this.approvedAt,
  });

  factory SubmissionReceived.fromJson(Map<String, dynamic> json) {
    return SubmissionReceived(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      challengeTitle: json['challengeTitle'] as String? ?? '',
      challengePoints: json['challengePoints'] as int? ?? 0,
      challengeType: parseChallengeType(json['challengeType'] as int? ?? 0),
      challengeStatus: parseChallengeStatus(
        json['challengeStatus'] as int? ?? 0,
      ),
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      proofUrl: json['proofUrl'] as String?,
      periodStart: DateTime.parse(json['periodStart'] as String),
      status: parseSubmissionStatus(json['status'] as int),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }
}
