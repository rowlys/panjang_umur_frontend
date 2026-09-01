import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panjang_umur_frontend/core/utils/result.dart';
import '../../domain/models/reward.dart';
import '../../domain/repositories/reward_repository.dart';

const _claimsPageSize = 20;

/// One page of reward claims I've made, with pagination state.
class RewardClaimsRedeemedPage {
  final List<RewardClaim> claims;
  final bool hasMore;
  final bool isLoadingMore;

  const RewardClaimsRedeemedPage({
    required this.claims,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  RewardClaimsRedeemedPage copyWith({
    List<RewardClaim>? claims,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RewardClaimsRedeemedPage(
      claims: claims ?? this.claims,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages claims I've made as a redeemer.
class RewardClaimsRedeemedController extends StateNotifier<AsyncValue<RewardClaimsRedeemedPage>> {
  final RewardRepository _rewardRepository;
  final String? giverId;

  RewardClaimsRedeemedController(this._rewardRepository, {this.giverId})
      : super(const AsyncValue.data(RewardClaimsRedeemedPage(claims: [], hasMore: false))) {
    loadClaims();
  }

  Future<void> loadClaims() async {
    state = const AsyncValue.loading();
    final result = await _rewardRepository.getClaimsRedeemed(giverId: giverId, limit: _claimsPageSize);

    switch (result) {
      case Success(data: final claims):
        state = AsyncValue.data(RewardClaimsRedeemedPage(
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

    final result = await _rewardRepository.getClaimsRedeemed(
      giverId: giverId,
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

  Future<Result<void>> fulfill(String claimId) async {
    final result = await _rewardRepository.fulfillClaim(claimId);
    if (result is Success<void>) {
      await loadClaims();
    }
    return result;
  }

  Future<Result<void>> requestRefund(String claimId, String reason) async {
    final result = await _rewardRepository.requestRefund(claimId, reason);
    if (result is Success<void>) {
      await loadClaims();
    }
    return result;
  }
}
