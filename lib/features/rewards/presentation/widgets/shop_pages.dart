import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/presentation/widgets/page_dots.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

class ShopPages extends StatefulWidget {
  final List<Widget> children;

  const ShopPages({super.key, required this.children});

  @override
  State<ShopPages> createState() => _ShopPagesState();
}

class _ShopPagesState extends State<ShopPages> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PageDots(count: widget.children.length, current: _page, color: HandDrawn.of(context).paper),
        ),
        Expanded(
          child: PageView(
            onPageChanged: (page) => setState(() => _page = page),
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
