import 'package:flutter/material.dart';
import '../../domain/models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final ChallengeType type;
  final DateTime? expiresAt;
  final String? statusLabel;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.points,
    required this.type,
    required this.onTap,
    this.expiresAt,
    this.statusLabel,
  });

  String get _typeLabel {
    switch (type) {
      case ChallengeType.bounty:
        return 'Bounty';
      case ChallengeType.daily:
        return 'Daily';
      case ChallengeType.weekly:
        return 'Weekly';
    }
  }

  IconData get _typeIcon {
    switch (type) {
      case ChallengeType.bounty:
        return Icons.emoji_events_outlined;
      case ChallengeType.daily:
        return Icons.today_outlined;
      case ChallengeType.weekly:
        return Icons.date_range_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text('$points pts'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(_typeIcon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(_typeLabel, style: theme.textTheme.labelMedium),
                  if (expiresAt != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Expires ${expiresAt!.toLocal().toString().split(' ').first}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                  if (statusLabel != null) ...[
                    const Spacer(),
                    Text(
                      statusLabel!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
