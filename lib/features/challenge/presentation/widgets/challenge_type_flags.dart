import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

import '../../domain/models/challenge.dart';

class ChallengeTypeFlags extends StatelessWidget {
  final ChallengeType? selected;
  final ValueChanged<ChallengeType?> onChanged;

  const ChallengeTypeFlags({super.key, required this.selected, required this.onChanged});

  static const double height = _Flag.selectedHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final type in ChallengeType.values)
          _Flag(
            type: type,
            isSelected: selected == type,
            isFaded: selected != null && selected != type,
            onTap: () => onChanged(selected == type ? null : type),
          ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  final ChallengeType type;
  final bool isSelected;
  final bool isFaded;
  final VoidCallback onTap;

  const _Flag({required this.type, required this.isSelected, required this.isFaded, required this.onTap});

  static const double selectedHeight = 40;

  (Color, IconData, String) _look(HandDrawn handDrawn) {
    switch (type) {
      case ChallengeType.bounty:
        return (handDrawn.bountyNote, Icons.emoji_events_outlined, 'Bounty');
      case ChallengeType.daily:
        return (handDrawn.dailyNote, Icons.today_outlined, 'Daily');
      case ChallengeType.weekly:
        return (handDrawn.weeklyNote, Icons.date_range_outlined, 'Weekly');
    }
  }

  @override
  Widget build(BuildContext context) {
    final handDrawn = HandDrawn.of(context);
    final (color, icon, label) = _look(handDrawn);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label challenges',
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isFaded ? 0.55 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: isSelected ? selectedHeight : 30,
              margin: const EdgeInsets.only(left: 6),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                boxShadow: handDrawn.dropShadow,
              ),
              child: Icon(icon, size: 18, color: handDrawn.ink),
            ),
          ),
        ),
      ),
    );
  }
}
