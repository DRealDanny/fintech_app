/// Pure Dart Card Entity.
class CardEntity {
  final String id;
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final bool isFrozen;
  final double spendingLimitDollars;
  final double currentSpentDollars;
  final bool isOnlinePaymentsEnabled;
  final bool isInternationalPaymentsEnabled;
  final String cardType; // 'virtual' | 'physical'

  const CardEntity({
    required this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.isFrozen = false,
    this.spendingLimitDollars = 5000.0,
    this.currentSpentDollars = 1240.50,
    this.isOnlinePaymentsEnabled = true,
    this.isInternationalPaymentsEnabled = true,
    this.cardType = 'virtual',
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
  }

  CardEntity copyWith({
    String? id,
    String? cardHolder,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    bool? isFrozen,
    double? spendingLimitDollars,
    double? currentSpentDollars,
    bool? isOnlinePaymentsEnabled,
    bool? isInternationalPaymentsEnabled,
    String? cardType,
  }) {
    return CardEntity(
      id: id ?? this.id,
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      isFrozen: isFrozen ?? this.isFrozen,
      spendingLimitDollars: spendingLimitDollars ?? this.spendingLimitDollars,
      currentSpentDollars: currentSpentDollars ?? this.currentSpentDollars,
      isOnlinePaymentsEnabled:
          isOnlinePaymentsEnabled ?? this.isOnlinePaymentsEnabled,
      isInternationalPaymentsEnabled:
          isInternationalPaymentsEnabled ?? this.isInternationalPaymentsEnabled,
      cardType: cardType ?? this.cardType,
    );
  }
}
