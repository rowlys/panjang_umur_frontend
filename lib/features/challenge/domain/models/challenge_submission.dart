enum SubmissionStatus { submitted, approved }

SubmissionStatus parseSubmissionStatus(int status) {
  switch (status) {
    case 0:
      return SubmissionStatus.submitted;
    case 1:
      return SubmissionStatus.approved;
    default:
      throw ArgumentError('Invalid submission status: $status');
  }
}

class ChallengeSubmission {
  final String id;
  final String challengeId;
  final String userId;
  final String? proofImageId;
  final DateTime periodStart;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? approvedAt;

  ChallengeSubmission({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.proofImageId,
    required this.periodStart,
    required this.status,
    required this.submittedAt,
    this.approvedAt,
  });

  factory ChallengeSubmission.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmission(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      proofImageId: json['proofImageId'] as String?,
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
      'proofImageId': proofImageId,
      'periodStart': periodStart.toIso8601String(),
      'status': status.index,
      'submittedAt': submittedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }
}
