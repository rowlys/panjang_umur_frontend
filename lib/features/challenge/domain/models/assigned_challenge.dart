import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';

class AssignedChallenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final ChallengeType type;
  final int resetDay;
  final User creator;
  final DateTime createdAt;
  final DateTime? expiresAt;

  AssignedChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.type,
    required this.resetDay,
    required this.creator,
    required this.createdAt,
    this.expiresAt,
  });

  factory AssignedChallenge.fromJson(Map<String, dynamic> json) {
    return AssignedChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      points: json['points'] as int,
      type: parseChallengeType(json['type'] as int),
      resetDay: json['resetDay'] as int? ?? 0,
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
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
      'resetDay': resetDay,
      'creator': creator.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
