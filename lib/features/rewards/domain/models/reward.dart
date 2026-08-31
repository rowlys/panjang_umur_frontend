enum RewardVisibility { public, restricted }

class Reward {
  final String id;
  final String title;
  final String description;
  final int cost;
  final String rewardGiverId;
  final RewardVisibility visibility;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.rewardGiverId,
    required this.visibility,
    required this.stock,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cost: json['cost'] as int,
      rewardGiverId: json['rewardGiverId'] as String,
      visibility: parseRewardVisibility(json['visibility'] as int),
      stock: json['stock'] as int,
      isAvailable: json['isAvailable'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cost': cost,
      'rewardGiverId': rewardGiverId,
      'visibility': visibility.index,
      'stock': stock,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

RewardVisibility parseRewardVisibility(int visibility) {
  switch (visibility) {
    case 0:
      return RewardVisibility.public;
    case 1:
      return RewardVisibility.restricted;
    default:
      throw ArgumentError('Invalid reward visibility: $visibility');
  }
}

enum ClaimStatus { pending, fulfilled, refundRequested, refunded }

class RewardClaim {
  final String id;
  final String rewardId;
  final String redeemerId;
  final String giverId;
  final int price;
  final ClaimStatus status;
  final DateTime redeemedAt;
  final DateTime? fulfilledAt;
  final DateTime? resolvedAt;
  final String redeemerUsername;

  RewardClaim({
    required this.id,
    required this.rewardId,
    required this.redeemerId,
    required this.giverId,
    required this.price,
    required this.status,
    required this.redeemedAt,
    this.fulfilledAt,
    this.resolvedAt,
    required this.redeemerUsername,
  });

  factory RewardClaim.fromJson(Map<String, dynamic> json) {
    return RewardClaim(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      redeemerId: json['redeemerId'] as String,
      giverId: json['giverId'] as String,
      price: json['price'] as int,
      status: parseClaimStatus(json['status'] as int),
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      fulfilledAt: json['fulfilledAt'] != null ? DateTime.parse(json['fulfilledAt'] as String) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      redeemerUsername: json['redeemerUsername'] as String,
    );
  }
}

ClaimStatus parseClaimStatus(int status) {
  switch (status) {
    case 0:
      return ClaimStatus.pending;
    case 1:
      return ClaimStatus.fulfilled;
    case 2:
      return ClaimStatus.refundRequested;
    case 3:
      return ClaimStatus.refunded;
    default:
      throw ArgumentError('Invalid claim status: $status');
  }
}
