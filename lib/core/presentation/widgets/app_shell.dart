import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/challenge/presentation/providers/challenge_providers.dart';
import '../../../features/chat/presentation/providers/chat_providers.dart';
import '../../../features/friends/presentation/providers/friend_providers.dart';
import '../../../features/rewards/presentation/providers/reward_providers.dart';
import '../../../features/transactions/presentation/providers/transaction_providers.dart';

const _challengesBranchIndex = 0;
const _myStoreBranchIndex = 1;
const _friendsBranchIndex = 2;
const _historyBranchIndex = 3;

typedef _Destination = ({IconData icon, IconData selectedIcon, String label});

const List<_Destination> _destinations = [
  (icon: Icons.task_alt_outlined, selectedIcon: Icons.task_alt, label: 'Challenges'),
  (icon: Icons.storefront_outlined, selectedIcon: Icons.storefront, label: 'My Store'),
  (icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Friends'),
  (icon: Icons.history_outlined, selectedIcon: Icons.history, label: 'History'),
  (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
];

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onItemTapped(WidgetRef ref, int index) {
    switch (index) {
      case _challengesBranchIndex:
        ref.read(assignedChallengeControllerProvider.notifier).getAssignedToMe();
        ref.read(createdChallengeControllerProvider.notifier).getCreatedByMe();
      case _myStoreBranchIndex:
        ref.read(myShopControllerProvider.notifier).getMyShop();
      case _friendsBranchIndex:
        ref.read(friendControllerProvider.notifier).getFriends();
        ref.read(friendRequestControllerProvider.notifier).getFriendRequests();
        ref.read(conversationSummariesControllerProvider.notifier).refresh();
      case _historyBranchIndex:
        ref.read(transactionHistoryControllerProvider.notifier).loadHistory();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navTheme = Theme.of(context).navigationBarTheme;

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Material(
                color: navTheme.backgroundColor,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: navTheme.height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final labelRoom = constraints.maxWidth - _destinations.length * _NavItem.collapsedWidth;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (final (index, destination) in _destinations.indexed)
                              _NavItem(
                                destination: destination,
                                selected: index == navigationShell.currentIndex,
                                maxLabelWidth: labelRoom,
                                onTap: () => _onItemTapped(ref, index),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final double maxLabelWidth;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.maxLabelWidth,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeInOutCubic;
  static const double _iconSize = 24;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 11.5, vertical: 9.5);
  static final double collapsedWidth = _iconSize + _padding.horizontal;

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).navigationBarTheme;
    final states = {if (selected) WidgetState.selected};
    final iconTheme = navTheme.iconTheme?.resolve(states);
    final fillColor = navTheme.indicatorColor ?? Colors.transparent;

    return Tooltip(
      message: destination.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        excludeSemantics: true,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            padding: _padding,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: selected ? fillColor : fillColor.withValues(alpha: 0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: iconTheme?.color),
                  duration: _duration,
                  curve: _curve,
                  builder: (context, color, _) => AnimatedSwitcher(
                    duration: _duration,
                    switchInCurve: _curve,
                    switchOutCurve: _curve,
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      key: ValueKey(selected),
                      color: color,
                      size: _iconSize,
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: selected ? 1 : 0),
                  duration: _duration,
                  curve: _curve,
                  builder: (context, shown, label) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: shown,
                      heightFactor: 1,
                      child: Opacity(opacity: ((shown - 0.4) / 0.6).clamp(0.0, 1.0), child: label),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxLabelWidth.clamp(0, double.infinity)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        destination.label,
                        style: navTheme.labelTextStyle?.resolve({WidgetState.selected}),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
