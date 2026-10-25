/// Pure Dart Transfer Entity.
/// Monetary fields are in integer cents to prevent floating point precision loss.
class TransferEntity {
  final String id;
  final String recipientName;
  final String recipientAccount;
  final String recipientBank;
  final int amountCents;
  final int feeCents;
  final String note;
  final DateTime timestamp;
  final String referenceNumber;
  final String status; // 'success', 'pending', 'failed'

  const TransferEntity({
    required this.id,
    required this.recipientName,
    required this.recipientAccount,
    required this.recipientBank,
    required this.amountCents,
    required this.feeCents,
    required this.note,
    required this.timestamp,
    required this.referenceNumber,
    this.status = 'success',
  });

  double get amountDollars => amountCents / 100.0;
  double get feeDollars => feeCents / 100.0;
  int get totalDeductionCents => amountCents + feeCents;
}
