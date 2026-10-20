import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';

import '../../domain/models/challenge.dart';
import '../providers/challenge_providers.dart';
import '../widgets/challenge_card.dart';
import '../widgets/board_search_field.dart';
import '../widgets/challenge_board.dart';
import '../widgets/challenge_type_flags.dart';

const _noteGrid = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: ChallengeCard.aspectRatio,
);

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(submissionsSubmittedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false);
      ref
          .read(submissionsReceivedControllerProvider(null).notifier)
          .loadSubmissions(showAll: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingTheirs =
        ref
            .watch(submissionsReceivedControllerProvider(null))
            .valueOrNull
            ?.submissions
            .length ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            tooltip: 'Pending submissions',
            onPressed: () => context.push('/challenges/pending-submissions'),
            icon: pendingTheirs > 0
                ? Badge(
                    label: Text('$pendingTheirs'),
                    child: const Icon(Icons.pending_actions_outlined),
                  )
                : const Icon(Icons.pending_actions_outlined),
          ),
        ],
      ),
      body: PageView(
        children: const [
          _AssignedBoard(),
          _CreatedBoard(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/challenges/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Challenge'),
      ),
    );
  }
}

Widget _boardMessage(String text) {
  return ListView(
    children: [
      const SizedBox(height: 120),
      Center(child: Text(text, textAlign: TextAlign.center)),
    ],
  );
}

Widget _filteredBoard({
  required String title,
  required String searchLabel,
  required ValueChanged<String> onSearchChanged,
  required ChallengeType? typeFilter,
  required ValueChanged<ChallengeType?> onTypeFilterChanged,
  required Widget notes,
}) {
  return ChallengeBoard(
    title: title,
    child: Column(
      children: [
        SizedBox(
          height: ChallengeTypeFlags.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                  child: BoardSearchField(label: searchLabel, onChanged: onSearchChanged),
                ),
              ),
              ChallengeTypeFlags(selected: typeFilter, onChanged: onTypeFilterChanged),
            ],
          ),
        ),
        Expanded(child: notes),
      ],
    ),
  );
}

bool _matchesPerson(User user, String query) =>
    user.name.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);

class _AssignedBoard extends ConsumerStatefulWidget {
  const _AssignedBoard();

  @override
  ConsumerState<_AssignedBoard> createState() => _AssignedBoardState();
}

class _AssignedBoardState extends ConsumerState<_AssignedBoard> {
  ChallengeType? _typeFilter;
  String _creatorQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignedChallengeControllerProvider);

    return _filteredBoard(
      title: 'Assigned to Me',
      searchLabel: 'From',
      onSearchChanged: (query) => setState(() => _creatorQuery = query.trim().toLowerCase()),
      typeFilter: _typeFilter,
      onTypeFilterChanged: (type) => setState(() => _typeFilter = type),
      notes: RefreshIndicator(
        onRefresh: () => ref.read(assignedChallengeControllerProvider.notifier).getAssignedToMe(),
        child: state.when(
          data: (challenges) {
            if (challenges.isEmpty) return _boardMessage('No challenges assigned to you.');

            final shown = challenges
                .where((c) => _typeFilter == null || c.type == _typeFilter)
                .where((c) => _matchesPerson(c.creator, _creatorQuery))
                .toList();
            if (shown.isEmpty) return _boardMessage('No matching challenges.');

            return GridView.builder(
              gridDelegate: _noteGrid,
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final challenge = shown[index];
                return ChallengeCard(
                  title: challenge.title,
                  description: challenge.description,
                  points: challenge.points,
                  type: challenge.type,
                  expiresAt: challenge.expiresAt,
                  creatorName: challenge.creator.name,
                  onTap: () => context.push('/challenges/${challenge.id}'),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _boardMessage('Failed to load challenges:\n$error'),
        ),
      ),
    );
  }
}

class _CreatedBoard extends ConsumerStatefulWidget {
  const _CreatedBoard();

  @override
  ConsumerState<_CreatedBoard> createState() => _CreatedBoardState();
}

class _CreatedBoardState extends ConsumerState<_CreatedBoard> {
  ChallengeType? _typeFilter;
  String _assigneeQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createdChallengeControllerProvider);

    return _filteredBoard(
      title: 'Created by Me',
      searchLabel: 'For',
      onSearchChanged: (query) => setState(() => _assigneeQuery = query.trim().toLowerCase()),
      typeFilter: _typeFilter,
      onTypeFilterChanged: (type) => setState(() => _typeFilter = type),
      notes: RefreshIndicator(
        onRefresh: () => ref.read(createdChallengeControllerProvider.notifier).getCreatedByMe(),
        child: state.when(
          data: (challenges) {
            if (challenges.isEmpty) return _boardMessage("You haven't created any challenges yet.");

            final shown = challenges
                .where((c) => _typeFilter == null || c.type == _typeFilter)
                .where((c) => !c.restricted || c.assignees.any((u) => _matchesPerson(u, _assigneeQuery)))
                .toList();
            if (shown.isEmpty) return _boardMessage('No matching challenges.');

            return GridView.builder(
              gridDelegate: _noteGrid,
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final challenge = shown[index];
                return ChallengeCard(
                  title: challenge.title,
                  description: challenge.description,
                  points: challenge.points,
                  type: challenge.type,
                  expiresAt: challenge.expiresAt,
                  statusLabel: challenge.status == ChallengeStatus.active ? null : challenge.status.name,
                  creatorName: 'You',
                  onTap: () => context.push('/challenges/${challenge.id}'),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _boardMessage('Failed to load challenges:\n$error'),
        ),
      ),
    );
  }
}
