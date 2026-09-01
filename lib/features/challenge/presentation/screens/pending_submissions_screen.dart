import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/challenge_submission.dart';
import '../../domain/models/submission_received.dart';
import '../../domain/models/submission_submitted.dart';
import '../providers/challenge_providers.dart';

class PendingSubmissionsScreen extends StatelessWidget {
  const PendingSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pending Submissions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Submissions'),
              Tab(text: 'Awaiting My Approval'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_MyPendingSubmissionsList(), _AwaitingMyApprovalList()],
        ),
      ),
    );
  }
}

class _MyPendingSubmissionsList extends ConsumerStatefulWidget {
  const _MyPendingSubmissionsList();

  @override
  ConsumerState<_MyPendingSubmissionsList> createState() =>
      _MyPendingSubmissionsListState();
}

class _MyPendingSubmissionsListState
    extends ConsumerState<_MyPendingSubmissionsList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(submissionsSubmittedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(submissionsSubmittedControllerProvider(null));

    return RefreshIndicator(
      onRefresh: () => ref
          .read(submissionsSubmittedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false),
      child: state.when(
        data: (page) {
          if (page.submissions.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nothing awaiting approval.')),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: page.submissions.length + (page.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= page.submissions.length) {
                return _LoadMoreFooter(
                  isLoading: page.isLoadingMore,
                  onLoadMore: () => ref
                      .read(
                        submissionsSubmittedControllerProvider(null).notifier,
                      )
                      .loadMore(),
                );
              }
              return _SubmittedTile(submission: page.submissions[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text('Failed to load submissions:\n$error')),
          ],
        ),
      ),
    );
  }
}

class _SubmittedTile extends StatelessWidget {
  final SubmissionSubmitted submission;

  const _SubmittedTile({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.challengeTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Submitted ${submission.submittedAt.toLocal().toString().split('.').first} · '
                    '${submission.challengePoints} pts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.hourglass_top, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}

class _AwaitingMyApprovalList extends ConsumerStatefulWidget {
  const _AwaitingMyApprovalList();

  @override
  ConsumerState<_AwaitingMyApprovalList> createState() =>
      _AwaitingMyApprovalListState();
}

class _AwaitingMyApprovalListState
    extends ConsumerState<_AwaitingMyApprovalList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(submissionsReceivedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(submissionsReceivedControllerProvider(null));

    return RefreshIndicator(
      onRefresh: () => ref
          .read(submissionsReceivedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false),
      child: state.when(
        data: (page) {
          if (page.submissions.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nothing awaiting your approval.')),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: page.submissions.length + (page.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= page.submissions.length) {
                return _LoadMoreFooter(
                  isLoading: page.isLoadingMore,
                  onLoadMore: () => ref
                      .read(
                        submissionsReceivedControllerProvider(null).notifier,
                      )
                      .loadMore(),
                );
              }
              return _ReceivedTile(submission: page.submissions[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load submissions:\n$error')),
      ),
    );
  }
}

class _ReceivedTile extends ConsumerStatefulWidget {
  final SubmissionReceived submission;

  const _ReceivedTile({required this.submission});

  @override
  ConsumerState<_ReceivedTile> createState() => _ReceivedTileState();
}

class _ReceivedTileState extends ConsumerState<_ReceivedTile> {
  bool _showProof = false;
  bool _isActing = false;

  Future<void> _handleApprove() async {
    setState(() => _isActing = true);
    final result = await ref
        .read(submissionsReceivedControllerProvider(null).notifier)
        .approve(widget.submission.id);
    if (!mounted) return;
    setState(() => _isActing = false);
    if (result is Error<ChallengeSubmission>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  child: Text(
                    submission.user.name.isNotEmpty
                        ? submission.user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${submission.user.name} (@${submission.user.username})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${submission.challengeTitle} · ${submission.challengePoints} pts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _isActing ? null : _handleApprove,
                  child: _isActing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Approve'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted ${submission.submittedAt.toLocal().toString().split('.').first}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

class _LoadMoreFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;

  const _LoadMoreFooter({required this.isLoading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : TextButton(onPressed: onLoadMore, child: const Text('Load more')),
    );
  }
}
