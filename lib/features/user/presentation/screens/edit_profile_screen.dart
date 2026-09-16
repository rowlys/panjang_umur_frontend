import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';

import '../providers/user_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isSavingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isSavingProfile = true);

    final result = await ref.read(userRepositoryProvider).updateProfile(
          _nameController.text.trim(),
          _usernameController.text.trim(),
        );

    if (result case Success()) {
      await ref.read(authControllerProvider.notifier).checkAuth();
    }

    if (!mounted) return;
    setState(() => _isSavingProfile = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSavingPassword = true);

    final result = await ref.read(userRepositoryProvider).changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );

    if (!mounted) return;
    setState(() => _isSavingPassword = false);

    switch (result) {
      case Success():
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSavingProfile ? null : _handleSaveProfile,
                  child: _isSavingProfile
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change Password', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty) ? 'Current password is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'New password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSavingPassword ? null : _handleChangePassword,
                  child: _isSavingPassword
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
