import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final ChallengeType type;
  final DateTime? expiresAt;
  final String? statusLabel;
  final String creatorName;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.points,
    required this.type,
    required this.creatorName,
    required this.onTap,
    this.expiresAt,
    this.statusLabel,
  });

  static const double aspectRatio = _artWidth / _artHeight;
  static const double _artWidth = 498;
  static const double _artHeight = 483;

  static const ink = Color(0xFF4E342E);

  String get _asset {
    switch (type) {
      case ChallengeType.bounty:
        return 'assets/images/challenges/bounty_note.png';
      case ChallengeType.daily:
        return 'assets/images/challenges/daily_note.png';
      case ChallengeType.weekly:
        return 'assets/images/challenges/weekly_note.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final footer = [
      if (expiresAt != null) 'Expires ${expiresAt!.toLocal().toString().split(' ').first}',
      ?statusLabel,
    ].join(' · ');

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _artWidth;
          TextStyle hand(double size) => TextStyle(fontFamily: 'PatrickHand', fontSize: size * s, color: ink, height: 1.1);

          return Stack(
            children: [
              Positioned.fill(child: Image.asset(_asset, fit: BoxFit.fill)),
              Positioned(
                left: 52 * s,
                top: 33 * s,
                right: (_artWidth - 312) * s,
                height: 113 * s,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'PatrickHand', fontSize: 58 * s, color: ink),
                  ),
                ),
              ),
              Positioned(
                left: 52 * s,
                top: 158 * s,
                right: (_artWidth - 425) * s,
                bottom: (_artHeight - 336) * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, box) => Text(
                          description,
                          maxLines: math.max(1, (box.maxHeight / (40 * s * 1.1)).floor()),
                          overflow: TextOverflow.ellipsis,
                          style: hand(40),
                        ),
                      ),
                    ),
                    if (footer.isNotEmpty)
                      Text(footer, maxLines: 1, overflow: TextOverflow.ellipsis, style: hand(34)),
                  ],
                ),
              ),
              Positioned(
                left: 340 * s,
                top: 62 * s,
                width: 66 * s,
                height: 58 * s,
                child: FittedBox(child: Text('$points', style: hand(40).copyWith(fontWeight: FontWeight.bold))),
              ),
              Positioned(
                left: 125 * s,
                top: 344 * s,
                right: (_artWidth - 425) * s,
                height: 72 * s,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(creatorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: hand(44)),
                ),
              ),
              Positioned(
                left: 20 * s,
                top: 24 * s,
                right: (_artWidth - 439) * s,
                bottom: (_artHeight - 421) * s,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onTap),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
