import 'dart:math';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/biller_entity.dart';

abstract class BillsLocalDataSource {
  Future<List<BillerEntity>> getBillers(BillerCategory category);
  Future<String> validateAccountNumber(String billerId, String accountNumber);
  Future<BillPaymentReceipt> payBill({
    required BillerEntity biller,
    required String accountNumber,
    required int amountCents,
  });
}

class BillsLocalDataSourceImpl implements BillsLocalDataSource {
  final List<BillerEntity> _mockBillers = const [
    // Electricity
    BillerEntity(
      id: 'b-elec-1',
      name: 'Tesla Powergrid',
      category: BillerCategory.electricity,
      code: 'TSLA-PWR',
      minAmountCents: 1000,
      maxAmountCents: 50000,
      accountLabel: 'Meter Number',
    ),
    BillerEntity(
      id: 'b-elec-2',
      name: 'ConEdison Electric',
      category: BillerCategory.electricity,
      code: 'CONED',
      minAmountCents: 1500,
      maxAmountCents: 100000,
      accountLabel: 'Account Number',
    ),
    BillerEntity(
      id: 'b-elec-3',
      name: 'CleanEnergy Solar',
      category: BillerCategory.electricity,
      code: 'CES-GREEN',
      minAmountCents: 1000,
      maxAmountCents: 40000,
      accountLabel: 'Consumer ID',
    ),
    // Mobile Airtime & Data
    BillerEntity(
      id: 'b-mob-1',
      name: 'AT&T 5G Wireless',
      category: BillerCategory.mobile,
      code: 'ATT-US',
      minAmountCents: 500,
      maxAmountCents: 30000,
      accountLabel: 'Phone Number',
    ),
    BillerEntity(
      id: 'b-mob-2',
      name: 'Verizon Ultra Band',
      category: BillerCategory.mobile,
      code: 'VRZ-US',
      minAmountCents: 500,
      maxAmountCents: 30000,
      accountLabel: 'Phone Number',
    ),
    BillerEntity(
      id: 'b-mob-3',
      name: 'T-Mobile Magenta',
      category: BillerCategory.mobile,
      code: 'TMOB-US',
      minAmountCents: 500,
      maxAmountCents: 25000,
      accountLabel: 'Phone Number',
    ),
    // Internet & Broadband
    BillerEntity(
      id: 'b-net-1',
      name: 'Starlink Satellite',
      category: BillerCategory.internet,
      code: 'STAR-LINK',
      minAmountCents: 5000,
      maxAmountCents: 20000,
      accountLabel: 'Kit / Service ID',
    ),
    BillerEntity(
      id: 'b-net-2',
      name: 'Google Fiber 2Gbps',
      category: BillerCategory.internet,
      code: 'GFIBER',
      minAmountCents: 7000,
      maxAmountCents: 15000,
      accountLabel: 'Fiber Account ID',
    ),
    // Water
    BillerEntity(
      id: 'b-wat-1',
      name: 'Municipal Water Board',
      category: BillerCategory.water,
      code: 'MUNI-H2O',
      minAmountCents: 1000,
      maxAmountCents: 50000,
      accountLabel: 'Customer ID',
    ),
  ];

  @override
  Future<List<BillerEntity>> getBillers(BillerCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockBillers.where((b) => b.category == category).toList();
  }

  @override
  Future<String> validateAccountNumber(String billerId, String accountNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (accountNumber.length < 6) {
      throw Exception('Invalid account number. Must be at least 6 digits.');
    }
    // Return customer verified name
    return 'Danny Adebayo (Verified Active)';
  }

  @override
  Future<BillPaymentReceipt> payBill({
    required BillerEntity biller,
    required String accountNumber,
    required int amountCents,
  }) async {
    final currentBalance = HiveStorage.walletBalanceCents;
    if (currentBalance < amountCents) {
      throw Exception('Insufficient funds. Available: \$${(currentBalance / 100).toStringAsFixed(2)}');
    }

    // Deduct integer cents safely
    final newBalance = currentBalance - amountCents;
    await HiveStorage.setWalletBalanceCents(newBalance);

    final rng = Random();
    final token = '${rng.nextInt(9000) + 1000}-${rng.nextInt(9000) + 1000}-${rng.nextInt(9000) + 1000}';
    final ref = 'BILL-${rng.nextInt(899999) + 100000}';

    return BillPaymentReceipt(
      referenceNumber: ref,
      billerName: biller.name,
      category: biller.category,
      accountNumber: accountNumber,
      amountCents: amountCents,
      timestamp: DateTime.now(),
      tokenCode: token,
    );
  }
}
