class GivenBalance {
  final String ownerId;
  final String ownerUsername;
  final String ownerName;
  final int balance;

  GivenBalance({
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerName,
    required this.balance,
  });

  factory GivenBalance.fromJson(Map<String, dynamic> json) {
    return GivenBalance(
      ownerId: json['ownerId'] as String,
      ownerUsername: json['ownerUsername'] as String? ?? 'Unknown',
      ownerName: json['ownerName'] as String? ?? 'Unknown',
      balance: json['balance'] as int,
    );
  }
}
