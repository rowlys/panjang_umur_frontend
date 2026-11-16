import 'package:flutter/material.dart';

/// A circular avatar for a user.
///
/// Falls back to the user's initial when there is no picture (or the picture
/// fails to load). The stored image is square; this widget only masks it into a
/// circle.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final scheme = Theme.of(context).colorScheme;

    Widget fallback() {
      final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: scheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: scheme.onPrimaryContainer,
          ),
        ),
      );
    }

    final url = imageUrl;
    final Widget content = (url == null || url.isEmpty)
        ? fallback()
        : Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null ? child : fallback(),
            errorBuilder: (context, error, stackTrace) => fallback(),
          );

    return Semantics(
      image: true,
      label: '$name profile picture',
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: SizedBox(width: size, height: size, child: content),
        ),
      ),
    );
  }
}
