import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/friends/presentation/providers/friend_providers.dart';

import '../../domain/models/reward.dart';
import '../providers/reward_providers.dart';

/// Creates a reward, or edits one when [rewardId] is given.
///
/// Editing never touches claims that were already redeemed: the API snapshots
/// the title and price on each claim.
class RewardFormScreen extends ConsumerWidget {
  final String? rewardId;

  const RewardFormScreen({super.key, this.rewardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rewardId == null) {
      return const _RewardForm();
    }

    final rewardAsync = ref.watch(rewardDetailProvider(rewardId!));

    return rewardAsync.when(
      data: (reward) => _RewardForm(reward: reward),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Reward')),
        body: Center(child: Text('Failed to load reward:\n$error')),
      ),
    );
  }
}

class _RewardForm extends ConsumerStatefulWidget {
  final Reward? reward;

  const _RewardForm({this.reward});

  @override
  ConsumerState<_RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends ConsumerState<_RewardForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _stockController;

  late RewardVisibility _visibility;
  late final Set<String> _allowedUserIds;
  bool _isSubmitting = false;

  bool get _isEditing => widget.reward != null;

  @override
  void initState() {
    super.initState();
    final reward = widget.reward;
    _titleController = TextEditingController(text: reward?.title ?? '');
    _descriptionController = TextEditingController(text: reward?.description ?? '');
    _costController = TextEditingController(text: reward?.cost.toString() ?? '');
    _stockController = TextEditingController(text: reward?.stock.toString() ?? '');
    _visibility = reward?.visibility ?? RewardVisibility.public;
    _allowedUserIds = {...?reward?.allowedUserIds};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Drop anyone who is no longer a friend: the API only accepts current
    // friends on a restricted reward.
    final friendIds = ref.read(friendControllerProvider).valueOrNull?.map((friend) => friend.id).toSet();
    final allowedUserIds = friendIds == null
        ? _allowedUserIds.toList()
        : _allowedUserIds.where(friendIds.contains).toList();

    if (_visibility == RewardVisibility.restricted && allowedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one friend for a restricted reward.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final cost = int.parse(_costController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final controller = ref.read(myShopControllerProvider.notifier);

    final Result<Reward> result;
    try {
      if (_isEditing) {
        result = await controller.update(
          widget.reward!.id,
          title: title,
          description: description,
          cost: cost,
          stock: stock,
          visibility: _visibility,
          allowedUserIds: _visibility == RewardVisibility.restricted ? allowedUserIds : const [],
        );
      } else {
        result = await controller.create(
          title: title,
          description: description,
          cost: cost,
          visibility: _visibility,
          stock: stock,
          allowedUserIds: _visibility == RewardVisibility.restricted ? allowedUserIds : const [],
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

  Future<void> _openAllowedUsersPicker(List<User> friends) async {
    final tempSelection = Set<String>.from(_allowedUserIds);

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
                            'Allowed friends',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _allowedUserIds
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
    final friendsState = ref.watch(friendControllerProvider);
    final noteStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Reward' : 'New Reward')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_isEditing) ...[
              Text(
                'Changes only affect future redemptions. Rewards that were already '
                'redeemed keep their original title and price.',
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
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost (points)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final cost = int.tryParse(value ?? '');
                if (cost == null || cost <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final stock = int.tryParse(value ?? '');
                if (stock == null || stock < 0) return 'Enter 0 or more';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text('Setting stock to 0 makes this reward unavailable.', style: noteStyle),
            const SizedBox(height: 16),
            Text('Visibility', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<RewardVisibility>(
              segments: const [
                ButtonSegment(value: RewardVisibility.public, label: Text('Public')),
                ButtonSegment(value: RewardVisibility.restricted, label: Text('Restricted')),
              ],
              selected: {_visibility},
              onSelectionChanged: (selection) => setState(() => _visibility = selection.first),
            ),
            if (_visibility == RewardVisibility.restricted) ...[
              const SizedBox(height: 16),
              Text(
                'Only the friends you select will be able to see and redeem this reward.',
                style: noteStyle,
              ),
              const SizedBox(height: 8),
              friendsState.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return const Text('You have no friends to restrict this reward to.');
                  }

                  final selectedFriends = friends.where((f) => _allowedUserIds.contains(f.id)).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedFriends.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedFriends.map((friend) {
                            return Chip(
                              label: Text(friend.name),
                              onDeleted: () => setState(() => _allowedUserIds.remove(friend.id)),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openAllowedUsersPicker(friends),
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
                  : Text(_isEditing ? 'Save Changes' : 'Create Reward'),
            ),
          ],
        ),
      ),
    );
  }
}
