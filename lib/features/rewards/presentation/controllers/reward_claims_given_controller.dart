import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/reward.dart';
import '../../domain/repositories/reward_repository.dart';

const _claimsPageSize = 20;

/// One page of reward claims made against my rewards, with pagination state.
class RewardClaimsGivenPage {
  final List<RewardClaim> claims;
  final bool hasMore;
  final bool isLoadingMore;

  const RewardClaimsGivenPage({
    required this.claims,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  RewardClaimsGivenPage copyWith({
    List<RewardClaim>? claims,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RewardClaimsGivenPage(
      claims: claims ?? this.claims,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages claims made against my rewards (I'm the giver).
class RewardClaimsGivenController extends StateNotifier<AsyncValue<RewardClaimsGivenPage>> {
  final RewardRepository _rewardRepository;
  final String? rewardId;

  RewardClaimsGivenController(this._rewardRepository, {this.rewardId})
      : super(const AsyncValue.data(RewardClaimsGivenPage(claims: [], hasMore: false))) {
    loadClaims();
  }

  Future<void> loadClaims() async {
    state = const AsyncValue.loading();
    final result = await _rewardRepository.getClaimsGiven(rewardId: rewardId, limit: _claimsPageSize);

    switch (result) {
      case Success(data: final claims):
        state = AsyncValue.data(RewardClaimsGivenPage(
          claims: claims,
          hasMore: claims.length == _claimsPageSize,
        ));
      case Error(failure: final error):
        state = AsyncValue.error(error.message, StackTrace.current);
    }
  }

  Future<Result<void>> loadMore() async {
    final page = state.valueOrNull;
    if (page == null || page.isLoadingMore || !page.hasMore || page.claims.isEmpty) {
      return Success(null);
    }

    state = AsyncValue.data(page.copyWith(isLoadingMore: true));

    final result = await _rewardRepository.getClaimsGiven(
      rewardId: rewardId,
      before: page.claims.last.redeemedAt,
      limit: _claimsPageSize,
    );

    switch (result) {
      case Success(data: final more):
        state = AsyncValue.data(page.copyWith(
          claims: [...page.claims, ...more],
          hasMore: more.length == _claimsPageSize,
          isLoadingMore: false,
        ));
        return Success(null);
      case Error(failure: final failure):
        state = AsyncValue.data(page.copyWith(isLoadingMore: false));
        return Error(failure);
    }
  }

  Future<Result<void>> approveRefund(String claimId) async {
    final result = await _rewardRepository.approveRefund(claimId);
    if (result is Success<void>) {
      await loadClaims();
    }
    return result;
  }
}
