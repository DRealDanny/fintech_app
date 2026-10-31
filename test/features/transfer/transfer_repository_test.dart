import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_app/core/errors/failure.dart';
import 'package:fintech_app/features/transfer/data/datasources/transfer_local_datasource.dart';
import 'package:fintech_app/features/transfer/data/datasources/transfer_remote_datasource.dart';
import 'package:fintech_app/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:fintech_app/features/transfer/domain/entities/beneficiary_entity.dart';
import 'package:fintech_app/features/transfer/domain/entities/transfer_entity.dart';

class MockTransferLocalDataSource implements TransferLocalDataSource {
  int balance = 500000; // $5,000.00
  String pin = '1234';

  @override
  Future<List<BeneficiaryEntity>> getBeneficiaries() async {
    return const [
      BeneficiaryEntity(
        id: 'ben_1',
        name: 'Sarah Connor',
        accountNumber: '4921',
        bankName: 'Chase',
        avatarInitial: 'S',
        colorHex: 0xFF6366F1,
      ),
    ];
  }

  @override
  Future<int> getBalanceCents() async => balance;

  @override
  Future<void> updateBalanceCents(int newBalanceCents) async {
    balance = newBalanceCents;
  }

  @override
  Future<bool> verifySecurityPin(String inputPin) async => inputPin == pin;

  @override
  Future<void> saveTransaction(TransferEntity transfer) async {}
}

class MockTransferRemoteDataSource implements TransferRemoteDataSource {
  int remoteBalance = 1000000;
  bool shouldFailRpc = false;

  @override
  Future<int> getWalletBalanceMinor({required String userId}) async => remoteBalance;

  @override
  Stream<int> streamWalletBalanceMinor({required String userId}) {
    return Stream.value(remoteBalance);
  }

  @override
  Future<Map<String, dynamic>> executeP2pTransfer({
    required String recipientId,
    required int amountMinor,
    required String reference,
  }) async {
    if (shouldFailRpc) {
      throw Exception('Database RPC exception: Insufficient funds');
    }
    remoteBalance -= amountMinor;
    return {'status': 'success', 'reference': reference};
  }
}

void main() {
  late MockTransferLocalDataSource mockLocal;
  late TransferRepositoryImpl repository;

  setUp(() {
    mockLocal = MockTransferLocalDataSource();
    repository = TransferRepositoryImpl(localDataSource: mockLocal);
  });

  const testBeneficiary = BeneficiaryEntity(
    id: 'ben_1',
    name: 'Sarah Connor',
    accountNumber: '4921',
    bankName: 'Chase',
    avatarInitial: 'S',
    colorHex: 0xFF6366F1,
  );

  test('returns validation failure when amount is zero or negative', () async {
    final result = await repository.executeTransfer(
      beneficiary: testBeneficiary,
      amountCents: 0,
      note: 'Coffee',
      pin: '1234',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have failed'),
    );
  });

  test('returns auth failure when PIN is incorrect', () async {
    final result = await repository.executeTransfer(
      beneficiary: testBeneficiary,
      amountCents: 2000,
      note: 'Dinner',
      pin: '9999',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<AuthFailure>()),
      (_) => fail('Should have failed'),
    );
  });

  test('returns validation failure when balance is insufficient', () async {
    final result = await repository.executeTransfer(
      beneficiary: testBeneficiary,
      amountCents: 99999999, // Way higher than 500000
      note: 'Car',
      pin: '1234',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should have failed'),
    );
  });

  test('executes transfer and updates balance on success', () async {
    final initialBalanceRes = await repository.getWalletBalanceCents();
    expect(initialBalanceRes.getOrElse((_) => 0), 500000);

    final result = await repository.executeTransfer(
      beneficiary: testBeneficiary,
      amountCents: 15000, // $150.00
      note: 'Lunch',
      pin: '1234',
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Transfer should have succeeded'),
      (receipt) {
        expect(receipt.recipientName, 'Sarah Connor');
        expect(receipt.amountCents, 15000);
        expect(receipt.status, 'success');
      },
    );

    final newBalanceRes = await repository.getWalletBalanceCents();
    expect(newBalanceRes.getOrElse((_) => 0), 500000 - 15000);
  });
}

