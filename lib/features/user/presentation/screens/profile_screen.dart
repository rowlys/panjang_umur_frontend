import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the global auth state that holds the current User object
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () {
              // Trigger the logout logic in the controller
              ref.read(authControllerProvider.notifier).logOut();
            },
          ),
        ],
      ),
      // .when cleanly handles the AsyncValue states
      body: authState.when(
        data: (user) {
          // Fallback if state is data but user is somehow null
          if (user == null) {
            return const Center(child: Text('Session expired. Please log in again.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity), // Forces column to center children
                
                // Avatar Placeholder
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Text(
                    // Display the first letter of the user's name
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Display Name
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Username
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Future Profile Actions (Settings, Edit, etc.)
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // TODO: Navigate to Edit Profile Screen
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // TODO: Navigate to Settings Screen
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading profile: $error')),
      ),
    );
  }
}