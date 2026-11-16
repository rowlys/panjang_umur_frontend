import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../user/presentation/providers/user_providers.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/presentation/widgets/user_avatar.dart';

import '../../../friends/presentation/widgets/add_friend_button.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  static const _debounceDuration = Duration(milliseconds: 300);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isDebouncing = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _stopDebounce();
      ref.read(userSearchControllerProvider.notifier).clearSearch();
      return;
    }

    if (!_isDebouncing) {
      setState(() => _isDebouncing = true);
    }

    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      _stopDebounce();
      ref.read(userSearchControllerProvider.notifier).searchUsers(query);
    });
  }

  void _stopDebounce() {
    if (!_isDebouncing) return;
    setState(() => _isDebouncing = false);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _stopDebounce();
    _searchController.clear();
    ref.read(userSearchControllerProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchControllerProvider);
    final barForeground = Theme.of(context).appBarTheme.foregroundColor;
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final isSearching = hasQuery && (_isDebouncing || searchState.isLoading);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: barForeground),
          cursorColor: barForeground,
          decoration: InputDecoration(
            hintText: 'Search by username...',
            hintStyle: TextStyle(color: barForeground?.withValues(alpha: 0.7)),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          autofocus: true, 
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          )
        ],
      ),
      body: isSearching
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Searching...'),
                ],
              ),
            )
          : searchState.when(
              data: (users) {
                if (!hasQuery) {
                  return const Center(child: Text('Type a username to find someone.'));
                }
                if (users.isEmpty) {
                  return const Center(child: Text('No user has that username.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserTile(user, ref);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
    );
  }

  Widget _buildUserTile(ForeignUser user, WidgetRef ref) {
    // Safely handle the nullable name
    final displayName = (user.name != null && user.name!.isNotEmpty) 
        ? user.name! 
        : user.username;

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          context.push('/foreign-profile/${user.id}');
        },
        child: UserAvatar(
          imageUrl: user.avatarUrl,
          name: displayName,
          radius: 20,
        ),
      ),
      title: Text(displayName),
      subtitle: Text('@${user.username}'),
      trailing: AddFriendButton(
        userId: user.id,
        initialStatus: user.friendStatus.index,
      ),
    );
  }

}