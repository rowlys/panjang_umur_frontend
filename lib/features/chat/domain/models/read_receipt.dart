class ReadReceipt {
  final String friendId;
  final DateTime readAt;

  ReadReceipt({required this.friendId, required this.readAt});

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      friendId: json['friendId'] as String,
      readAt: DateTime.parse(json['readAt'] as String),
    );
  }
}
