enum BillerCategory {
  electricity,
  mobile,
  internet,
  water,
}

/// Pure Dart entity representing a utility biller / service provider.
class BillerEntity {
  final String id;
  final String name;
  final BillerCategory category;
  final String code;
  final int minAmountCents;
  final int maxAmountCents;
  final String accountLabel; // e.g. "Meter Number", "Mobile Phone Number", "Account ID"

  const BillerEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.code,
    required this.minAmountCents,
    required this.maxAmountCents,
    required this.accountLabel,
  });
}

/// Pure Dart entity representing a completed bill payment receipt.
class BillPaymentReceipt {
  final String referenceNumber;
  final String billerName;
  final BillerCategory category;
  final String accountNumber;
  final int amountCents;
  final DateTime timestamp;
  final String tokenCode; // e.g., prepaid recharge token or receipt code

  const BillPaymentReceipt({
    required this.referenceNumber,
    required this.billerName,
    required this.category,
    required this.accountNumber,
    required this.amountCents,
    required this.timestamp,
    required this.tokenCode,
  });

  double get amountDollars => amountCents / 100.0;
}
