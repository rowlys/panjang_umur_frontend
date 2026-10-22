import 'package:flutter/material.dart';
import 'package:panjang_umur_frontend/core/theme/app_theme.dart';

import '../../domain/models/reward.dart';

class RewardShelf extends StatelessWidget {
  final List<Reward> rewards;
  final ValueChanged<Reward> onTap;

  const RewardShelf({super.key, required this.rewards, required this.onTap});

  static const double _panelWidth = 944;
  static const double _margin = 39;
  static const double _top = 48;
  static const double _gap = 32;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / _panelWidth;

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            _margin * s,
            _top * s,
            _margin * s,
            _top * s + MediaQuery.paddingOf(context).bottom,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: _ItemBox.aspectRatio,
            crossAxisSpacing: _gap * s,
            mainAxisSpacing: _gap * s,
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) => _ItemBox(reward: rewards[index], onTap: () => onTap(rewards[index])),
        );
      },
    );
  }
}

class _ItemBox extends StatelessWidget {
  final Reward reward;
  final VoidCallback onTap;

  const _ItemBox({required this.reward, required this.onTap});

  static const double aspectRatio = _artWidth / _artHeight;
  static const double _artWidth = 417;
  static const double _artHeight = 385;

  @override
  Widget build(BuildContext context) {
    final handDrawn = HandDrawn.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / _artWidth;
        TextStyle hand(double size) => handDrawn.hand(size * s).copyWith(color: handDrawn.paper, height: 1.1);

        return Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/images/rewards/item_box.png', fit: BoxFit.fill)),
            Padding(
              padding: EdgeInsets.fromLTRB(36 * s, 40 * s, 50 * s, 32 * s),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reward.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: hand(52),
                    ),
                    SizedBox(height: 12 * s),
                    Text('${reward.cost} pts', maxLines: 1, style: hand(40)),
                    if (!reward.isAvailable) Text('Unavailable', maxLines: 1, style: hand(40)),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(40 * s)),
              ),
            ),
          ],
        );
      },
    );
  }
}
