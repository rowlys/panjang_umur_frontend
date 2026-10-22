import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

class BoardSearchField extends StatefulWidget {
  final String label;
  final ValueChanged<String> onChanged;

  const BoardSearchField({super.key, required this.label, required this.onChanged});

  @override
  State<BoardSearchField> createState() => _BoardSearchFieldState();
}

class _BoardSearchFieldState extends State<BoardSearchField> {
  final _controller = TextEditingController();

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
    final handDrawn = HandDrawn.of(context);
    final textStyle = handDrawn.hand(18).copyWith(height: 1.2, leadingDistribution: TextLeadingDistribution.even);

    return Row(
      children: [
        Text(widget.label, style: handDrawn.hand(20)),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: handDrawn.paper,
              borderRadius: BorderRadius.circular(3),
              boxShadow: handDrawn.dropShadow,
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              cursorColor: handDrawn.ink,
              cursorHeight: 18,
              style: textStyle,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'anyone',
                hintStyle: textStyle.copyWith(color: handDrawn.ink.withValues(alpha: 0.45)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? Icon(Icons.search, size: 18, color: handDrawn.ink.withValues(alpha: 0.6))
                      : IconButton(
                          tooltip: 'Clear',
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(28, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          iconSize: 18,
                          color: handDrawn.ink,
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
