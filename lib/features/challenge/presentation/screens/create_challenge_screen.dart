import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';

import '../../domain/models/challenge.dart';
import '../providers/challenge_providers.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();

  ChallengeType _type = ChallengeType.bounty;
  int _resetDay = 0;
  DateTime? _expiresAt;
  final Set<String> _selectedAssigneeIds = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    Result<Challenge> result;
    try {
      result = await ref.read(createdChallengeControllerProvider.notifier).create(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            points: int.parse(_pointsController.text.trim()),
            type: _type,
            resetDay: _type == ChallengeType.weekly ? _resetDay : null,
            assigneeIds: _selectedAssigneeIds.toList(),
            expiresAt: _expiresAt,
          );
    } catch (e) {
      // The create request itself may have already succeeded server-side by
      // the time an error surfaces here (e.g. the post-create refresh inside
      // the controller failing) — either way, the button must not stay stuck
      // on loading, so this always resolves the UI state before propagating.
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        Navigator.of(context).pop();
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Future<void> _pickExpiresAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  Future<void> _openAssigneePicker(List<User> friends) async {
    final tempSelection = Set<String>.from(_selectedAssigneeIds);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assign to friends',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedAssigneeIds
                                ..clear()
                                ..addAll(tempSelection));
                              Navigator.of(sheetContext).pop();
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          final isSelected = tempSelection.contains(friend.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(friend.name),
                            subtitle: Text('@${friend.username}'),
                            onChanged: (checked) {
                              setSheetState(() {
                                if (checked ?? false) {
                                  tempSelection.add(friend.id);
                                } else {
                                  tempSelection.remove(friend.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the autoDispose provider alive for as long as this screen is on
    // screen. Without this, if nothing else happens to be watching it (e.g.
    // the "Created by Me" tab isn't the active one), Riverpod disposes the
    // controller mid-request and the post-create refresh throws, aborting
    // _handleCreate before it can reset the submit button's loading state.
    ref.watch(createdChallengeControllerProvider);
    final friendsState = ref.watch(friendControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Challenge')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pointsController,
              decoration: const InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final points = int.tryParse(value ?? '');
                if (points == null || points <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ChallengeType>(
              segments: const [
                ButtonSegment(value: ChallengeType.bounty, label: Text('Bounty')),
                ButtonSegment(value: ChallengeType.daily, label: Text('Daily')),
                ButtonSegment(value: ChallengeType.weekly, label: Text('Weekly')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            if (_type == ChallengeType.weekly) ...[
              const SizedBox(height: 16),
              Text('Resets on', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _resetDay,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Sunday')),
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _resetDay = value);
                },
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _expiresAt == null
                    ? 'No expiry date'
                    : 'Expires ${_expiresAt!.toLocal().toString().split(' ').first}',
              ),
              trailing: TextButton(
                onPressed: _pickExpiresAt,
                child: Text(_expiresAt == null ? 'Set date' : 'Change'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Assign to friends (optional)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Leave empty to make this an open challenge any of your friends can take on.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            friendsState.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return const Text('You have no friends to assign yet.');
                }

                final selectedFriends = friends.where((f) => _selectedAssigneeIds.contains(f.id)).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedFriends.isEmpty)
                      Text(
                        'Open to all friends',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedFriends.map((friend) {
                          return Chip(
                            label: Text(friend.name),
                            onDeleted: () => setState(() => _selectedAssigneeIds.remove(friend.id)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _openAssigneePicker(friends),
                      icon: const Icon(Icons.person_add_alt),
                      label: Text(selectedFriends.isEmpty ? 'Select friends' : 'Edit selection'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Failed to load friends:\n$error'),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _handleCreate,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
