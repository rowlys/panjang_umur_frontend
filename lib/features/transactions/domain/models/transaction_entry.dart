enum TransactionRole { owner, giver }

enum TransactionMovementType { earned, spent }

enum TransactionReferenceType { claim, submission }

enum TransactionSign { credit, debit, neutral }

enum TransactionDomainFilter {
  rewards,
  challenges;

  String get queryValue => name;
}

TransactionRole parseTransactionRole(String value) {
  switch (value) {
    case 'owner':
      return TransactionRole.owner;
    case 'giver':
      return TransactionRole.giver;
    default:
      throw ArgumentError('Invalid transaction role: $value');
  }
}

TransactionMovementType parseTransactionMovementType(int value) {
  switch (value) {
    case 0:
      return TransactionMovementType.earned;
    case 1:
      return TransactionMovementType.spent;
    default:
      throw ArgumentError('Invalid transaction type: $value');
  }
}

TransactionReferenceType parseTransactionReferenceType(int value) {
  switch (value) {
    case 0:
      return TransactionReferenceType.claim;
    case 1:
      return TransactionReferenceType.submission;
    default:
      throw ArgumentError('Invalid transaction reference type: $value');
  }
}

/// One row of the point-movement ledger: either something the viewer earned
/// or spent themselves (role = owner), or something that happened within the
/// viewer's own point economy, e.g. a friend spending on the viewer's reward
/// (role = giver).
class TransactionEntry {
  final String id;
  final TransactionRole role;
  final TransactionMovementType type;
  final int amount;
  final TransactionReferenceType referenceType;
  final String referenceId;
  final String title;
  final String counterpartyUsername;
  final DateTime timestamp;

  TransactionEntry({
    required this.id,
    required this.role,
    required this.type,
    required this.amount,
    required this.referenceType,
    required this.referenceId,
    required this.title,
    required this.counterpartyUsername,
    required this.timestamp,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'] as String,
      role: parseTransactionRole(json['role'] as String),
      type: parseTransactionMovementType(json['type'] as int),
      amount: json['amount'] as int,
      referenceType: parseTransactionReferenceType(
        json['referenceType'] as int,
      ),
      referenceId: json['referenceId'] as String,
      title: json['title'] as String? ?? '',
      counterpartyUsername:
          json['counterpartyUsername'] as String? ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get label {
    switch (role) {
      case TransactionRole.owner:
        switch (type) {
          case TransactionMovementType.spent:
            return 'Bought';
          case TransactionMovementType.earned:
            return referenceType == TransactionReferenceType.claim
                ? 'Refunded'
                : 'Earned';
        }
      case TransactionRole.giver:
        switch (type) {
          case TransactionMovementType.spent:
            return 'Sold';
          case TransactionMovementType.earned:
            return referenceType == TransactionReferenceType.claim
                ? 'Refunded to buyer'
                : 'Paid out';
        }
    }
  }

  TransactionSign get sign {
    if (role != TransactionRole.owner) return TransactionSign.neutral;
    return type == TransactionMovementType.earned
        ? TransactionSign.credit
        : TransactionSign.debit;
  }
}
