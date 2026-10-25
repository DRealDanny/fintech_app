enum TransactionType { credit, debit }

enum TransactionCategory {
  all,
  transfer,
  shopping,
  salary,
  bills,
  dining,
  entertainment,
}

enum TransactionStatus { completed, pending, failed }

/// Business entity representing a financial transaction.
/// Pure Dart (Zero Flutter imports).
class TransactionEntity {
  final String id;
  final String title;
  final String subtitle;
  final int amountCents;
  final TransactionType type;
  final TransactionCategory category;
  final TransactionStatus status;
  final DateTime timestamp;
  final String referenceNumber;
  final String? counterparty;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amountCents,
    required this.type,
    required this.category,
    required this.status,
    required this.timestamp,
    required this.referenceNumber,
    this.counterparty,
  });

  bool get isCredit => type == TransactionType.credit;
  double get amountDollars => amountCents / 100.0;
}
