class PointBalance {
  final String giverId;
  final String giverUsername;
  final String giverName;
  final int balance;

  PointBalance({
    required this.giverId,
    required this.giverUsername,
    required this.giverName,
    required this.balance,
  });

  factory PointBalance.fromJson(Map<String, dynamic> json) {
    return PointBalance(
      giverId: json['giverId'] as String,
      giverUsername: json['giverUsername'] as String? ?? 'Unknown',
      giverName: json['giverName'] as String? ?? 'Unknown',
      balance: json['balance'] as int,
    );
  }
}
