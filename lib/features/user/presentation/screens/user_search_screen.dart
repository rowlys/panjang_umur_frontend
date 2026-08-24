import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../user/presentation/providers/user_providers.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';

import '../../../friends/presentation/widgets/add_friend_button.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(userSearchControllerProvider.notifier).searchUsers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          autofocus: true, 
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              ref.read(userSearchControllerProvider.notifier).clearSearch();
            },
          )
        ],
      ),
      body: searchState.when(
        data: (users) {
          if (users.isEmpty && _searchController.text.isNotEmpty) {
            return const Center(child: Text('No users found.'));
          } else if (users.isEmpty) {
            return const Center(child: Text('Type to search for users.'));
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
    
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          context.push('/profile/${user.id}');
        },
        child: CircleAvatar(
          child: Text(initial),
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