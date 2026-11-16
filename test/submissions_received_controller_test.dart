import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:panjang_umur_frontend/core/models/user.dart';
import 'package:panjang_umur_frontend/core/error/failures.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/challenge_submission.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/proof_upload_slot.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_received.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/models/submission_submitted.dart';
import 'package:panjang_umur_frontend/features/challenge/domain/repositories/challenge_submission_repository.dart';
import 'package:panjang_umur_frontend/features/challenge/presentation/controllers/submissions_received_controller.dart';

class _FakeSubmissionRepository implements ChallengeSubmissionRepository {
  _FakeSubmissionRepository(this.submissions);

  final List<SubmissionReceived> submissions;
  Completer<Result<ChallengeSubmission>>? approveCompleter;

  @override
  Future<Result<List<SubmissionReceived>>> getSubmissionsReceived({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  }) async {
    return Success(submissions);
  }

  @override
  Future<Result<ChallengeSubmission>> approve(String submissionId) {
    approveCompleter = Completer<Result<ChallengeSubmission>>();
    return approveCompleter!.future;
  }

  @override
  Future<Result<Challenge>> submit(String challengeId, {String? proofImageId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<SubmissionSubmitted>>> getSubmissionsSubmitted({
    String? challengeId,
    String? statusFilter,
    DateTime? before,
    int? limit,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ProofUploadSlot>> getProofUploadSlot() {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> uploadProofImage({required String uploadUrl, required List<int> fileBytes}) {
    throw UnimplementedError();
  }
}

SubmissionReceived _submission(String id) {
  return SubmissionReceived(
    id: id,
    challengeId: 'challenge',
    challengeTitle: 'Morning walk',
    challengePoints: 10,
    challengeType: ChallengeType.daily,
    challengeStatus: ChallengeStatus.active,
    userId: 'user-$id',
    user: User(id: 'user-$id', name: 'Friend $id', username: 'friend$id'),
    periodStart: DateTime.utc(2026, 11, 16),
    status: SubmissionStatus.submitted,
    submittedAt: DateTime.utc(2026, 11, 16, 8),
  );
}

ChallengeSubmission _approved(String id) {
  return ChallengeSubmission(
    id: id,
    challengeId: 'challenge',
    userId: 'user-$id',
    periodStart: DateTime.utc(2026, 11, 16),
    status: SubmissionStatus.approved,
    submittedAt: DateTime.utc(2026, 11, 16, 8),
    approvedAt: DateTime.utc(2026, 11, 16, 9),
  );
}

void main() {
  test('approve removes the row immediately, before the request finishes', () async {
    final repository = _FakeSubmissionRepository([_submission('a'), _submission('b')]);
    final controller = SubmissionsReceivedController(repository);

    await controller.loadSubmissions();

    final approval = controller.approve('a');

    expect(controller.state.value!.submissions.map((s) => s.id), ['b']);

    repository.approveCompleter!.complete(Success(_approved('a')));
    await approval;

    expect(controller.state.value!.submissions.map((s) => s.id), ['b']);
  });

  test('a failed approve puts the row back where it was', () async {
    final repository = _FakeSubmissionRepository([_submission('a'), _submission('b')]);
    final controller = SubmissionsReceivedController(repository);

    await controller.loadSubmissions();

    final approval = controller.approve('a');
    repository.approveCompleter!.complete(Error(ServerFailure('nope')));
    await approval;

    expect(controller.state.value!.submissions.map((s) => s.id), ['a', 'b']);
  });

  test('the All tab keeps the row and flips it to approved', () async {
    final repository = _FakeSubmissionRepository([_submission('a')]);
    final controller = SubmissionsReceivedController(repository);

    await controller.loadSubmissions(showAll: true);

    final approval = controller.approve('a');

    final visible = controller.state.value!.submissions.single;
    expect(visible.id, 'a');
    expect(visible.status, SubmissionStatus.approved);

    repository.approveCompleter!.complete(Success(_approved('a')));
    await approval;
  });
}
