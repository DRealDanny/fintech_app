import 'dart:math';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_local_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferLocalDataSource localDataSource;

  const TransferRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<BeneficiaryEntity>>> getBeneficiaries() async {
    try {
      final list = await localDataSource.getBeneficiaries();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Failed to load beneficiaries: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getWalletBalanceCents() async {
    try {
      final balance = await localDataSource.getBalanceCents();
      return Right(balance);
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve balance: $e'));
    }
  }

  @override
  Future<Either<Failure, TransferEntity>> executeTransfer({
    required BeneficiaryEntity beneficiary,
    required int amountCents,
    required String note,
    required String pin,
  }) async {
    try {
      if (amountCents <= 0) {
        return const Left(ValidationFailure('Transfer amount must be greater than zero'));
      }

      // Verify PIN
      final isPinValid = await localDataSource.verifySecurityPin(pin);
      if (!isPinValid) {
        return const Left(AuthFailure('Incorrect security PIN. Authorization declined.'));
      }

      // Check current balance
      final currentBalance = await localDataSource.getBalanceCents();
      const feeCents = 0; // $0 for internal transfer
      final totalRequiredCents = amountCents + feeCents;

      if (currentBalance < totalRequiredCents) {
        return Left(ValidationFailure(
          'Insufficient funds. Required: \$${(totalRequiredCents / 100).toStringAsFixed(2)}, Available: \$${(currentBalance / 100).toStringAsFixed(2)}',
        ));
      }

      // Deduct balance
      final newBalance = currentBalance - totalRequiredCents;
      await localDataSource.updateBalanceCents(newBalance);

      // Generate receipt
      final random = Random();
      final refNum = 'TRX-${random.nextInt(899999) + 100000}';
      final transfer = TransferEntity(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        recipientName: beneficiary.name,
        recipientAccount: beneficiary.accountNumber,
        recipientBank: beneficiary.bankName,
        amountCents: amountCents,
        feeCents: feeCents,
        note: note.isEmpty ? 'Funds Transfer' : note,
        timestamp: DateTime.now(),
        referenceNumber: refNum,
        status: 'success',
      );

      await localDataSource.saveTransaction(transfer);
      return Right(transfer);
    } catch (e) {
      return Left(ServerFailure('Transfer processing failed: $e'));
    }
  }
}
