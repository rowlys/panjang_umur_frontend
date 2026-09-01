import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/challenge.dart';
import '../providers/challenge_providers.dart';
import '../widgets/challenge_card.dart';

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Assigned to Me'),
              Tab(text: 'Created by Me'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AssignedTab(),
            _CreatedTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/challenges/new'),
          icon: const Icon(Icons.add),
          label: const Text('New Challenge'),
        ),
      ),
    );
  }
}

class _TypeFilterBar extends StatelessWidget {
  final ChallengeType? value;
  final ValueChanged<ChallengeType?> onChanged;

  const _TypeFilterBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SegmentedButton<ChallengeType?>(
          segments: const [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(value: ChallengeType.bounty, label: Text('Bounty')),
            ButtonSegment(value: ChallengeType.daily, label: Text('Daily')),
            ButtonSegment(value: ChallengeType.weekly, label: Text('Weekly')),
          ],
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}

class _AssignedTab extends ConsumerStatefulWidget {
  const _AssignedTab();

  @override
  ConsumerState<_AssignedTab> createState() => _AssignedTabState();
}

class _AssignedTabState extends ConsumerState<_AssignedTab> {
  ChallengeType? _typeFilter;
  String? _creatorFilter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignedChallengeControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(assignedChallengeControllerProvider.notifier).getAssignedToMe(),
      child: state.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No challenges assigned to you.')),
              ],
            );
          }

          final creators = <String, String>{};
          for (final challenge in challenges) {
            creators[challenge.creator.id] = challenge.creator.name;
          }

          final filtered = challenges.where((challenge) {
            if (_typeFilter != null && challenge.type != _typeFilter) return false;
            if (_creatorFilter != null && challenge.creator.id != _creatorFilter) return false;
            return true;
          }).toList();

          return Column(
            children: [
              _TypeFilterBar(
                value: _typeFilter,
                onChanged: (value) => setState(() => _typeFilter = value),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(
                  children: [
                    Text('From:', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    DropdownButton<String?>(
                      value: _creatorFilter,
                      hint: const Text('All friends'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('All friends')),
                        ...creators.entries.map(
                          (entry) => DropdownMenuItem<String?>(value: entry.key, child: Text(entry.value)),
                        ),
                      ],
                      onChanged: (value) => setState(() => _creatorFilter = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No challenges match this filter.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final challenge = filtered[index];
                          return ChallengeCard(
                            title: challenge.title,
                            description: challenge.description,
                            points: challenge.points,
                            type: challenge.type,
                            expiresAt: challenge.expiresAt,
                            statusLabel: 'by ${challenge.creator.username}',
                            onTap: () => context.push('/challenges/${challenge.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text('Failed to load challenges:\n$error')),
          ],
        ),
      ),
    );
  }
}

class _CreatedTab extends ConsumerStatefulWidget {
  const _CreatedTab();

  @override
  ConsumerState<_CreatedTab> createState() => _CreatedTabState();
}

class _CreatedTabState extends ConsumerState<_CreatedTab> {
  ChallengeType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createdChallengeControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(createdChallengeControllerProvider.notifier).getCreatedByMe(),
      child: state.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text("You haven't created any challenges yet.")),
              ],
            );
          }

          final filtered = _typeFilter == null
              ? challenges
              : challenges.where((challenge) => challenge.type == _typeFilter).toList();

          return Column(
            children: [
              _TypeFilterBar(
                value: _typeFilter,
                onChanged: (value) => setState(() => _typeFilter = value),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No challenges match this filter.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final challenge = filtered[index];
                          return ChallengeCard(
                            title: challenge.title,
                            description: challenge.description,
                            points: challenge.points,
                            type: challenge.type,
                            expiresAt: challenge.expiresAt,
                            statusLabel: challenge.status.name,
                            onTap: () => context.push('/challenges/${challenge.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text('Failed to load challenges:\n$error')),
          ],
        ),
      ),
    );
  }
}
