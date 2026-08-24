import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/friend_providers.dart';

class AddFriendButton extends ConsumerStatefulWidget {
  final String userId;
  final int initialStatus;

  const AddFriendButton({
    super.key,
    required this.userId,
    required this.initialStatus,
  });

  @override
  ConsumerState<AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends ConsumerState<AddFriendButton> {
  bool _isLoading = false;
  late int _currentStatus;

  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
  }

  @override
  void didUpdateWidget(covariant AddFriendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _currentStatus = widget.initialStatus;
    }
  }

  Future<void> _handlePressed() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(friendRequestControllerProvider.notifier).sendFriendRequest(widget.userId);
      
      if (mounted) {
        setState(() {
          _currentStatus = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    switch (_currentStatus) {
      case 0: // Not Friends
        return FilledButton.icon(
          onPressed: _handlePressed,
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add'),
        );
      case 1: // Pending
        return FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.pending, size: 18),
          label: Text('Pending'),
        );
      case 2: // Friends
        return OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.check, size: 18),
          label: Text('Friends'),
        );
      default:
        return SizedBox.shrink();
    }
  }
}