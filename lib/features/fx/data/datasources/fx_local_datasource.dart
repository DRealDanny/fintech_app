import 'dart:math';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/currency_pocket_entity.dart';

abstract class FxLocalDataSource {
  Future<List<CurrencyPocketEntity>> getPockets();
  Future<FxSwapReceipt> swapCurrency({
    required String fromCode,
    required String toCode,
    required int fromAmountCents,
  });
}

class FxLocalDataSourceImpl implements FxLocalDataSource {
  List<CurrencyPocketEntity>? _pockets;

  List<CurrencyPocketEntity> _initPockets() {
    final usdBalance = HiveStorage.walletBalanceCents;
    return [
      CurrencyPocketEntity(
        code: 'USD',
        symbol: '\$',
        name: 'US Dollar',
        balanceCents: usdBalance,
        flagEmoji: '🇺🇸',
        rateToUSD: 1.0,
      ),
      const CurrencyPocketEntity(
        code: 'EUR',
        symbol: '€',
        name: 'Euro',
        balanceCents: 415000, // €4,150.00
        flagEmoji: '🇪🇺',
        rateToUSD: 0.92,
      ),
      const CurrencyPocketEntity(
        code: 'GBP',
        symbol: '£',
        name: 'British Pound',
        balanceCents: 289000, // £2,890.00
        flagEmoji: '🇬🇧',
        rateToUSD: 0.79,
      ),
      const CurrencyPocketEntity(
        code: 'JPY',
        symbol: '¥',
        name: 'Japanese Yen',
        balanceCents: 35000000, // ¥350,000
        flagEmoji: '🇯🇵',
        rateToUSD: 154.20,
      ),
    ];
  }

  @override
  Future<List<CurrencyPocketEntity>> getPockets() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pockets ??= _initPockets();
    // Keep USD synced with HiveStorage
    final idx = _pockets!.indexWhere((p) => p.code == 'USD');
    if (idx != -1) {
      _pockets![idx] = _pockets![idx].copyWith(balanceCents: HiveStorage.walletBalanceCents);
    }
    return List.from(_pockets!);
  }

  @override
  Future<FxSwapReceipt> swapCurrency({
    required String fromCode,
    required String toCode,
    required int fromAmountCents,
  }) async {
    _pockets ??= _initPockets();

    final fromIdx = _pockets!.indexWhere((p) => p.code == fromCode);
    final toIdx = _pockets!.indexWhere((p) => p.code == toCode);

    if (fromIdx == -1 || toIdx == -1) {
      throw Exception('Unsupported currency pair');
    }

    final fromPocket = _pockets![fromIdx];
    final toPocket = _pockets![toIdx];

    if (fromPocket.balanceCents < fromAmountCents) {
      throw Exception('Insufficient ${fromPocket.code} funds');
    }

    // Rate calculation: from USD normalized
    final rate = toPocket.rateToUSD / fromPocket.rateToUSD;
    final toAmountCents = (fromAmountCents * rate).round();

    // Deduct and credit
    _pockets![fromIdx] = fromPocket.copyWith(
      balanceCents: fromPocket.balanceCents - fromAmountCents,
    );
    _pockets![toIdx] = toPocket.copyWith(
      balanceCents: toPocket.balanceCents + toAmountCents,
    );

    // If USD was involved, update Hive
    if (fromCode == 'USD') {
      await HiveStorage.setWalletBalanceCents(_pockets![fromIdx].balanceCents);
    } else if (toCode == 'USD') {
      await HiveStorage.setWalletBalanceCents(_pockets![toIdx].balanceCents);
    }

    final rng = Random();
    return FxSwapReceipt(
      referenceNumber: 'FX-${rng.nextInt(899999) + 100000}',
      fromCode: fromCode,
      toCode: toCode,
      fromAmountCents: fromAmountCents,
      toAmountCents: toAmountCents,
      appliedRate: rate,
      timestamp: DateTime.now(),
    );
  }
}
