/// Pure Dart business entity representing a multi-currency pocket.
class CurrencyPocketEntity {
  final String code; // USD, EUR, GBP, JPY
  final String symbol; // $, €, £, ¥
  final String name; // US Dollar, Euro, British Pound, Japanese Yen
  final int balanceCents; // Stored in lowest unit (cents/pence/yen)
  final String flagEmoji;
  final double rateToUSD; // 1 USD = rate units of this currency

  const CurrencyPocketEntity({
    required this.code,
    required this.symbol,
    required this.name,
    required this.balanceCents,
    required this.flagEmoji,
    required this.rateToUSD,
  });

  double get balanceDollars => balanceCents / 100.0;

  CurrencyPocketEntity copyWith({int? balanceCents}) {
    return CurrencyPocketEntity(
      code: code,
      symbol: symbol,
      name: name,
      balanceCents: balanceCents ?? this.balanceCents,
      flagEmoji: flagEmoji,
      rateToUSD: rateToUSD,
    );
  }
}

/// Pure Dart entity representing a completed FX swap receipt.
class FxSwapReceipt {
  final String referenceNumber;
  final String fromCode;
  final String toCode;
  final int fromAmountCents;
  final int toAmountCents;
  final double appliedRate;
  final DateTime timestamp;

  const FxSwapReceipt({
    required this.referenceNumber,
    required this.fromCode,
    required this.toCode,
    required this.fromAmountCents,
    required this.toAmountCents,
    required this.appliedRate,
    required this.timestamp,
  });
}
