import 'package:flutter/material.dart';

import 'challenge_card.dart';

class BoardSearchField extends StatefulWidget {
  final String label;
  final ValueChanged<String> onChanged;

  const BoardSearchField({super.key, required this.label, required this.onChanged});

  @override
  State<BoardSearchField> createState() => _BoardSearchFieldState();
}

class _BoardSearchFieldState extends State<BoardSearchField> {
  final _controller = TextEditingController();

  static const _paper = Color(0xFFFFF6E0);
  static const _textStyle = TextStyle(
    fontFamily: 'PatrickHand',
    fontSize: 18,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    color: ChallengeCard.ink,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label, style: const TextStyle(fontFamily: 'PatrickHand', fontSize: 20, color: ChallengeCard.ink)),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _paper,
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2))],
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              cursorColor: ChallengeCard.ink,
              cursorHeight: 18,
              style: _textStyle,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'anyone',
                hintStyle: _textStyle.copyWith(color: ChallengeCard.ink.withValues(alpha: 0.45)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? Icon(Icons.search, size: 18, color: ChallengeCard.ink.withValues(alpha: 0.6))
                      : IconButton(
                          tooltip: 'Clear',
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          color: ChallengeCard.ink,
                          icon: const Icon(Icons.close),
                          onPressed: _clear,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
