import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/user_avatar.dart';

class BalanceTile extends StatelessWidget {
  final String name;
  final String username;
  final int balance;
  final String? avatarUrl;

  const BalanceTile({
    super.key,
    required this.name,
    required this.username,
    required this.balance,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: UserAvatar(
          imageUrl: avatarUrl,
          name: name,
          radius: 20,
        ),
        title: Text(name),
        subtitle: Text('@$username'),
        trailing: Text(
          '$balance pts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}
