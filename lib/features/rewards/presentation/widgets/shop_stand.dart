import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';

typedef _Layer = ({String asset, Rect rect});

class ShopStand extends StatefulWidget {
  final Gender? shopkeeper;
  final Widget child;

  const ShopStand({super.key, required this.shopkeeper, required this.child});

  @override
  State<ShopStand> createState() => _ShopStandState();
}

class _ShopStandState extends State<ShopStand> with SingleTickerProviderStateMixin {
  static const _asset = 'assets/images/rewards/shop_stand.png';
  static const double _imageWidth = 1080;
  static const _stretchArea = Rect.fromLTRB(120, 900, 960, 1700);
  static const _counterPanel = EdgeInsets.fromLTRB(68, 795, 68, 75);

  static const _Layer _background = (
    asset: 'assets/images/rewards/shop_background.png',
    rect: Rect.fromLTWH(0, 0, 1080, 836),
  );
  static const _Layer _maleBody = (
    asset: 'assets/images/rewards/male_body.png',
    rect: Rect.fromLTWH(345, 199, 393, 564),
  );
  static const _Layer _maleHand = (
    asset: 'assets/images/rewards/male_hand.png',
    rect: Rect.fromLTWH(291, 600, 150, 128),
  );
  static const _Layer _femaleBody = (
    asset: 'assets/images/rewards/female_body.png',
    rect: Rect.fromLTWH(364, 196, 387, 567),
  );
  static const _Layer _femaleHand = (
    asset: 'assets/images/rewards/female_hand.png',
    rect: Rect.fromLTWH(310, 470, 185, 252),
  );

  late final _wave = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible && widget.shopkeeper != null) _wave.forward(from: 0);
    _visible = visible;
  }

  @override
  void didUpdateWidget(ShopStand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopkeeper == null && widget.shopkeeper != null) _wave.forward(from: 0);
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  void _waveAgain() => _wave.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final shopkeeper = widget.shopkeeper;
    final (body, hand) = shopkeeper == Gender.female ? (_femaleBody, _femaleHand) : (_maleBody, _maleHand);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = _imageWidth / constraints.maxWidth;
        Widget at(_Layer layer, Widget child) => Positioned.fromRect(
              rect: Rect.fromLTRB(
                layer.rect.left / scale,
                layer.rect.top / scale,
                layer.rect.right / scale,
                layer.rect.bottom / scale,
              ),
              child: child,
            );
        Widget image(_Layer layer) => Image.asset(layer.asset, fit: BoxFit.fill);

        return Stack(
          fit: StackFit.expand,
          children: [
            at(_background, image(_background)),
            if (shopkeeper != null) at(body, GestureDetector(onTap: _waveAgain, child: image(body))),
            IgnorePointer(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _imageWidth,
                  height: constraints.maxHeight * scale,
                  child: Image.asset(_asset, centerSlice: _stretchArea, fit: BoxFit.fill),
                ),
              ),
            ),
            if (shopkeeper != null)
              at(
                hand,
                GestureDetector(
                  onTap: _waveAgain,
                  child: AnimatedBuilder(
                    animation: _wave,
                    builder: (context, child) => Transform.rotate(
                      angle: 0.35 * math.sin(_wave.value * 12 * math.pi) * (1 - _wave.value * _wave.value),
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                    child: image(hand),
                  ),
                ),
              ),
            Padding(padding: _counterPanel / scale, child: widget.child),
          ],
        );
      },
    );
  }
}
