import 'package:flutter/material.dart';

import 'challenge_card.dart';

class ChallengeBoard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChallengeBoard({super.key, required this.title, required this.child});

  static const _image = ExactAssetImage('assets/images/challenges/challenge_board.png', scale: 3);
  static const _stretchArea = Rect.fromLTRB(67, 67, 280, 467);
  static const _corkPadding = EdgeInsets.fromLTRB(18, 57, 18, 18);
  static const double _pinClearance = 68;
  static const double _titleHeight = 39;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(image: _image, centerSlice: _stretchArea),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: _pinClearance,
                  right: _pinClearance,
                  top: 0,
                  height: _titleHeight,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(fontFamily: 'PatrickHand', fontSize: 26, color: ChallengeCard.ink),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: _corkPadding,
                    child: ClipRect(child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
