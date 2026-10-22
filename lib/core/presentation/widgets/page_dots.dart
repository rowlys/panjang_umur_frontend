import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

class PageDots extends StatelessWidget {
  final int count;
  final int current;
  final Color? color;

  const PageDots({super.key, required this.count, required this.current, this.color});

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? HandDrawn.of(context).ink;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: i == current ? 1 : 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
