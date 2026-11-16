class PointBalance {
  final String giverId;
  final String giverUsername;
  final String giverName;
  final String? giverAvatarUrl;
  final int balance;

  PointBalance({
    required this.giverId,
    required this.giverUsername,
    required this.giverName,
    required this.balance,
    this.giverAvatarUrl,
  });

  factory PointBalance.fromJson(Map<String, dynamic> json) {
    return PointBalance(
      giverId: json['giverId'] as String,
      giverUsername: json['giverUsername'] as String? ?? 'Unknown',
      giverName: json['giverName'] as String? ?? 'Unknown',
      giverAvatarUrl: json['giverAvatarUrl'] as String?,
      balance: json['balance'] as int,
    );
  }
}
