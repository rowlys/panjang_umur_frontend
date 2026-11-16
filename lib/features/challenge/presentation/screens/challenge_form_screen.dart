import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';

import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_detail.dart';
import '../providers/challenge_providers.dart';

/// Creates a challenge, or edits one when [challengeId] is given.
///
/// Type, reset day and assignees are fixed after creation: changing them would
/// move period boundaries or the participant list. Points are snapshotted on
/// each submission, so editing them only affects future submissions.
class ChallengeFormScreen extends ConsumerWidget {
  final String? challengeId;

  const ChallengeFormScreen({super.key, this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (challengeId == null) {
      return const _ChallengeForm();
    }

    final challengeAsync = ref.watch(challengeDetailProvider(challengeId!));

    return challengeAsync.when(
      data: (challenge) => _ChallengeForm(challenge: challenge),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: Center(child: Text('Failed to load challenge:\n$error')),
      ),
    );
  }
}

class _ChallengeForm extends ConsumerStatefulWidget {
  final ChallengeDetail? challenge;

  const _ChallengeForm({this.challenge});

  @override
  ConsumerState<_ChallengeForm> createState() => _ChallengeFormState();
}

class _ChallengeFormState extends ConsumerState<_ChallengeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;

  late ChallengeType _type;
  late int _resetDay;
  DateTime? _expiresAt;
  final Set<String> _selectedAssigneeIds = {};
  bool _isSubmitting = false;

  bool get _isEditing => widget.challenge != null;

  @override
  void initState() {
    super.initState();
    final challenge = widget.challenge;
    _titleController = TextEditingController(text: challenge?.title ?? '');
    _descriptionController = TextEditingController(text: challenge?.description ?? '');
    _pointsController = TextEditingController(text: challenge?.points.toString() ?? '');
    _type = challenge?.type ?? ChallengeType.bounty;
    _resetDay = challenge?.resetDay ?? 0;
    _expiresAt = challenge?.expiresAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final points = int.parse(_pointsController.text.trim());
    final controller = ref.read(createdChallengeControllerProvider.notifier);

    final Result<Challenge> result;
    try {
      if (_isEditing) {
        result = await controller.update(
          widget.challenge!.id,
          title: title,
          description: description,
          points: points,
          expiresAt: _expiresAt,
        );
      } else {
        result = await controller.create(
          title: title,
          description: description,
          points: points,
          type: _type,
          resetDay: _type == ChallengeType.weekly ? _resetDay : null,
          assigneeIds: _selectedAssigneeIds.toList(),
          expiresAt: _expiresAt,
        );
      }
    } catch (e) {
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
    final firstDate = DateTime(now.year, now.month, now.day);
    final current = _expiresAt;
    final initialDate = current != null && current.isAfter(firstDate) ? current : now.add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
                        color: Theme.of(context).colorScheme.outline,
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

  String _typeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.bounty:
        return 'Bounty';
      case ChallengeType.daily:
        return 'Daily';
      case ChallengeType.weekly:
        return 'Weekly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendControllerProvider);
    final noteStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Challenge' : 'New Challenge')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_isEditing) ...[
              Text(
                '${_typeLabel(_type)} · ${widget.challenge!.restricted ? 'assigned to ${widget.challenge!.assignees.length} friends' : 'open to all friends'}'
                '\nType and assignees cannot be changed after creation. Already submitted '
                'challenges keep the points they were submitted for.',
                style: noteStyle,
              ),
              const SizedBox(height: 16),
            ],
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
            if (!_isEditing) ...[
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
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              Text('Assign to friends (optional)', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Leave empty to make this an open challenge any of your friends can take on.',
                style: noteStyle,
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
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _handleSave,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Create Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
