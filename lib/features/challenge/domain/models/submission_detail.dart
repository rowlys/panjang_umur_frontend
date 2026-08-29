import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';

class SubmissionDetail {
  final String id;
  final String challengeId;
  final String userId;
  final User user;
  final String? proofUrl;
  final DateTime periodStart;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? approvedAt;

  SubmissionDetail({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.user,
    this.proofUrl,
    required this.periodStart,
    required this.status,
    required this.submittedAt,
    this.approvedAt,
  });

  factory SubmissionDetail.fromJson(Map<String, dynamic> json) {
    return SubmissionDetail(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      proofUrl: json['ProofURL'] as String?,
      periodStart: DateTime.parse(json['periodStart'] as String),
      status: parseSubmissionStatus(json['status'] as int),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'user': user.toJson(),
      'ProofURL': proofUrl,
      'periodStart': periodStart.toIso8601String(),
      'status': status.index,
      'submittedAt': submittedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }
}
