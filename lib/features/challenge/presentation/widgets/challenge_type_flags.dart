import 'package:flutter/material.dart';

import '../../domain/models/challenge.dart';
import 'challenge_card.dart';

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

  (Color, IconData, String) get _look {
    switch (type) {
      case ChallengeType.bounty:
        return (const Color(0xFFFFDB5A), Icons.emoji_events_outlined, 'Bounty');
      case ChallengeType.daily:
        return (const Color(0xFFFBA73A), Icons.today_outlined, 'Daily');
      case ChallengeType.weekly:
        return (const Color(0xFFE5EA7F), Icons.date_range_outlined, 'Weekly');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _look;

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
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2))],
              ),
              child: Icon(icon, size: 18, color: ChallengeCard.ink),
            ),
          ),
        ),
      ),
    );
  }
}
