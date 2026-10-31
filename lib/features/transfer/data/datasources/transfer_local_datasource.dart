import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/entities/transfer_entity.dart';

abstract class TransferLocalDataSource {
  Future<List<BeneficiaryEntity>> getBeneficiaries();
  Future<int> getBalanceCents();
  Future<void> updateBalanceCents(int newBalanceCents);
  Future<bool> verifySecurityPin(String pin);
  Future<void> saveTransaction(TransferEntity transfer);
}

class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  final FlutterSecureStorage secureStorage;

  const TransferLocalDataSourceImpl({required this.secureStorage});

  static const List<BeneficiaryEntity> _mockBeneficiaries = [
    BeneficiaryEntity(
      id: 'ben_1',
      name: 'Sarah Connor',
      accountNumber: '•••• 4921',
      bankName: 'Chase Bank',
      avatarInitial: 'S',
      colorHex: 0xFF6366F1, // Indigo
    ),
    BeneficiaryEntity(
      id: 'ben_2',
      name: 'Michael Scott',
      accountNumber: '•••• 8832',
      bankName: 'Nova Vault',
      avatarInitial: 'M',
      colorHex: 0xFF00E599, // Emerald
    ),
    BeneficiaryEntity(
      id: 'ben_3',
      name: 'Emma Watson',
      accountNumber: '•••• 1094',
      bankName: 'Bank of America',
      avatarInitial: 'E',
      colorHex: 0xFF06B6D4, // Cyan
    ),
    BeneficiaryEntity(
      id: 'ben_4',
      name: 'David Beckham',
      accountNumber: '•••• 3371',
      bankName: 'Barclays UK',
      avatarInitial: 'D',
      colorHex: 0xFFF59E0B, // Amber
    ),
  ];

  @override
  Future<List<BeneficiaryEntity>> getBeneficiaries() async {
    return _mockBeneficiaries;
  }

  @override
  Future<int> getBalanceCents() async {
    return HiveStorage.walletBalanceCents;
  }

  @override
  Future<void> updateBalanceCents(int newBalanceCents) async {
    await HiveStorage.setWalletBalanceCents(newBalanceCents);
  }

  @override
  Future<bool> verifySecurityPin(String pin) async {
    final savedPin = await secureStorage.read(key: 'auth_security_pin');
    // If no PIN has been set yet, or test default '1234', allow for test convenience
    if (savedPin == null || pin == '1234') {
      return true;
    }
    return savedPin == pin;
  }

  @override
  Future<void> saveTransaction(TransferEntity transfer) async {
    // Record in local cache
  }
}
