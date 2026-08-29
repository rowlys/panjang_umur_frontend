import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/auth/presentation/providers/auth_providers.dart';

import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_detail.dart';
import '../providers/challenge_providers.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  final String id;

  const ChallengeDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeDetailProvider(id));
    final currentUser = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge')),
      body: challengeAsync.when(
        data: (challenge) {
          final isCreator = currentUser != null && challenge.creator.id == currentUser.id;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(challengeDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Text(
                        challenge.creator.name.isNotEmpty ? challenge.creator.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCreator ? 'Created by you' : 'By ${challenge.creator.name} (@${challenge.creator.username})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (challenge.description.isNotEmpty) ...[
                  Text(challenge.description),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${challenge.points} pts')),
                    Chip(label: Text(_typeLabel(challenge.type))),
                    Chip(label: Text(challenge.status.name)),
                    if (challenge.type == ChallengeType.weekly)
                      Chip(label: Text('Resets on ${_weekdayLabel(challenge.resetDay)}')),
                    if (challenge.expiresAt != null)
                      Chip(label: Text('Expires ${challenge.expiresAt!.toLocal().toString().split(' ').first}')),
                  ],
                ),
                const SizedBox(height: 24),
                if (isCreator)
                  _CreatorSection(challengeId: id, status: challenge.status)
                else
                  _AssigneeSection(
                    challengeId: id,
                    status: challenge.status,
                    mySubmissionStatus: challenge.mySubmissionStatus,
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load challenge:\n$error')),
      ),
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

  String _weekdayLabel(int resetDay) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (resetDay < 0 || resetDay > 6) return 'day $resetDay';
    return days[resetDay];
  }
}




class _AssigneeSection extends ConsumerStatefulWidget {
  final String challengeId;
  final ChallengeStatus status;
  final SubmissionStatus? mySubmissionStatus;

  const _AssigneeSection({
    required this.challengeId,
    required this.status,
    required this.mySubmissionStatus,
  });

  @override
  ConsumerState<_AssigneeSection> createState() => _AssigneeSectionState();
}

class _AssigneeSectionState extends ConsumerState<_AssigneeSection> {
  bool _isSubmitting = false;

  static const double _maxPreviewHeight = 640;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;
  double? _pickedImageAspectRatio;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (pickedFile == null) return; // user backed out of the picker — not an error

    // AspectRatio needs width/height up front to lay itself out, but nothing
    // in Dart exposes an image's dimensions without decoding it first — so we
    // decode once here, synchronously with the pick, rather than guessing.
    final bytes = await pickedFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final aspectRatio = frame.image.width / frame.image.height;

    if (!mounted) return; // widget could be gone by the time decoding finishes
    setState(() {
      _pickedImage = pickedFile;
      _pickedImageAspectRatio = aspectRatio;
    });
  }

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  void _removePickedImage() {
    setState(() {
      _pickedImage = null;
      _pickedImageAspectRatio = null;
    });
  }

  // Set right after a successful submit so the button updates instantly,
  // without waiting for the challengeDetailProvider refetch to land. Once
  // fresh server data arrives with a matching status, this becomes redundant;
  // if the widget's own mySubmissionStatus ever changes, we drop the override
  // and trust the server value again.
  SubmissionStatus? _optimisticStatus;

  @override
  void didUpdateWidget(covariant _AssigneeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mySubmissionStatus != widget.mySubmissionStatus) {
      _optimisticStatus = null;
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final proofImageBytes = _pickedImage != null ? await _pickedImage!.readAsBytes() : null;

    final result = await ref
        .read(challengeSubmissionControllerProvider(widget.challengeId).notifier)
        .submit(proofImageBytes: proofImageBytes);

    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() {
          _isSubmitting = false;
          _optimisticStatus = SubmissionStatus.submitted;
        });
        ref.invalidate(challengeDetailProvider(widget.challengeId));
        ref.read(assignedChallengeControllerProvider.notifier).getAssignedToMe();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted for approval!')),
        );
      case Error(failure: final failure):
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status != ChallengeStatus.active) {
      return const SizedBox.shrink();
    }

    final effectiveStatus = _optimisticStatus ?? widget.mySubmissionStatus;

    if (effectiveStatus == SubmissionStatus.approved) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
        label: const Text('Approved'),
      );
    }

    if (effectiveStatus == SubmissionStatus.submitted) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top),
        label: const Text('Awaiting Approval'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedImage != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxPreviewHeight),
            child: AspectRatio(
              // Matching the box's ratio to the image's own ratio means
              // BoxFit.cover has nothing to crop — it just scales.
              aspectRatio: _pickedImageAspectRatio ?? 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_pickedImage!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: _isSubmitting ? null : _showImageSourcePicker,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Change'),
              ),
              TextButton.icon(
                onPressed: _isSubmitting ? null : _removePickedImage,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ] else
          InkWell(
            onTap: _isSubmitting ? null : _showImageSourcePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Add photo proof (optional)',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _handleSubmit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: const Text('Submit for Approval'),
        ),
      ],
    );
  }
}

class _CreatorSection extends ConsumerStatefulWidget {
  final String challengeId;
  final ChallengeStatus status;

  const _CreatorSection({required this.challengeId, required this.status});

  @override
  ConsumerState<_CreatorSection> createState() => _CreatorSectionState();
}

class _CreatorSectionState extends ConsumerState<_CreatorSection> {
  bool _isActing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(challengeSubmissionControllerProvider(widget.challengeId).notifier).loadSubmissions();
    });
  }

  Future<void> _handleApprove(String submissionId) async {
    setState(() => _isActing = true);
    final result = await ref
        .read(challengeSubmissionControllerProvider(widget.challengeId).notifier)
        .approve(submissionId);
    if (!mounted) return;
    setState(() => _isActing = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission approved!')),
        );
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  Future<void> _handleShowAllChanged(bool showAll) async {
    await ref
        .read(challengeSubmissionControllerProvider(widget.challengeId).notifier)
        .loadSubmissions(showAll: showAll);
  }

  Future<void> _handleLoadMore() async {
    final result =
        await ref.read(challengeSubmissionControllerProvider(widget.challengeId).notifier).loadMore();
    if (!mounted) return;
    if (result is Error<void>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure.message)),
      );
    }
  }

  Future<void> _handleCancel() async {
    setState(() => _isActing = true);
    await ref.read(createdChallengeControllerProvider.notifier).cancel(widget.challengeId);
    if (!mounted) return;
    setState(() => _isActing = false);
    ref.invalidate(challengeDetailProvider(widget.challengeId));
  }

  Future<void> _handleDelete() async {
    setState(() => _isActing = true);
    await ref.read(createdChallengeControllerProvider.notifier).delete(widget.challengeId);
    if (!mounted) return;
    setState(() => _isActing = false);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final submissionsState = ref.watch(challengeSubmissionControllerProvider(widget.challengeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.status == ChallengeStatus.active) ...[
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isActing ? null : _handleCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isActing ? null : _handleDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Text('Submissions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        submissionsState.when(
          data: (page) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Pending')),
                    ButtonSegment(value: true, label: Text('All')),
                  ],
                  selected: {page.showAll},
                  onSelectionChanged: (selection) => _handleShowAllChanged(selection.first),
                ),
                const SizedBox(height: 8),
                if (page.submissions.isEmpty)
                  Text(page.showAll ? 'No submissions yet.' : 'No submissions awaiting approval.')
                else
                  ...page.submissions.map((submission) => _SubmissionTile(
                        submission: submission,
                        isActing: _isActing,
                        onApprove: () => _handleApprove(submission.id),
                      )),
                if (page.hasMore)
                  Center(
                    child: page.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextButton(onPressed: _handleLoadMore, child: const Text('Load more')),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Failed to load submissions:\n$error'),
        ),
      ],
    );
  }
}

class _SubmissionTile extends StatefulWidget {
  final SubmissionDetail submission;
  final bool isActing;
  final VoidCallback onApprove;

  const _SubmissionTile({
    required this.submission,
    required this.isActing,
    required this.onApprove,
  });

  @override
  State<_SubmissionTile> createState() => _SubmissionTileState();
}

class _SubmissionTileState extends State<_SubmissionTile> {
  // Hidden by default — a photo only downloads once the creator explicitly
  // asks to see it, so a challenge with a long submission history never
  // fires off a burst of image requests just because the list rendered.
  bool _showProof = false;

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;
    final isPending = submission.status == SubmissionStatus.submitted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Text(
                    submission.user.name.isNotEmpty ? submission.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${submission.user.name} (@${submission.user.username})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                isPending
                    ? FilledButton(
                        onPressed: widget.isActing ? null : widget.onApprove,
                        child: const Text('Approve'),
                      )
                    : const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted ${submission.submittedAt.toLocal().toString().split('.').first}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (submission.proofUrl != null) ...[
              const SizedBox(height: 8),
              if (!_showProof)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showProof = true),
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('View proof photo'),
                )
              else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    submission.proofUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _showProof = false),
                  icon: const Icon(Icons.visibility_off_outlined, size: 18),
                  label: const Text('Hide photo'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
