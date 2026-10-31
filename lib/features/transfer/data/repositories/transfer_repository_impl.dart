import 'dart:math';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/supabase_client.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_local_datasource.dart';
import '../datasources/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferLocalDataSource localDataSource;
  final TransferRemoteDataSource? remoteDataSource;

  const TransferRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

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
      final currentUserId = SupabaseService.isInitialized
          ? SupabaseService.client.auth.currentUser?.id
          : null;

      // 1. Try fetching live balance from Supabase if online and authenticated
      if (remoteDataSource != null && currentUserId != null) {
        try {
          final remoteBalance = await remoteDataSource!.getWalletBalanceMinor(
            userId: currentUserId,
          );
          // Sync with local cache
          await localDataSource.updateBalanceCents(remoteBalance);
          return Right(remoteBalance);
        } catch (_) {
          // If remote fails, fall through to local cache
        }
      }

      // 2. Fall back to cached local storage
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

      // 1. Verify Security PIN via local secure storage
      final isPinValid = await localDataSource.verifySecurityPin(pin);
      if (!isPinValid) {
        return const Left(AuthFailure('Incorrect security PIN. Authorization declined.'));
      }

      const feeCents = 0; // $0 for internal transfer
      final random = Random();
      final refNum = 'TRX-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(899) + 100}';

      final currentUserId = SupabaseService.isInitialized
          ? SupabaseService.client.auth.currentUser?.id
          : null;

      // 2. Production Path: Execute via PostgreSQL RPC on Supabase (Atomic Row-Locking)
      if (remoteDataSource != null && currentUserId != null) {
        try {
          final rpcResult = await remoteDataSource!.executeP2pTransfer(
            recipientId: beneficiary.id,
            amountMinor: amountCents,
            reference: refNum,
          );

          if (rpcResult['status'] != 'success') {
            return Left(ServerFailure(rpcResult['message']?.toString() ?? 'Transfer failed'));
          }

          // Fetch fresh balance after transfer
          final updatedBalance = await remoteDataSource!.getWalletBalanceMinor(
            userId: currentUserId,
          );
          await localDataSource.updateBalanceCents(updatedBalance);

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
          return Left(ServerFailure('Transfer declined: $e'));
        }
      }

      // 3. Fallback / Offline Prototype Mode (when Supabase credentials are not yet entered)
      final currentBalance = await localDataSource.getBalanceCents();
      final totalRequiredCents = amountCents + feeCents;

      if (currentBalance < totalRequiredCents) {
        return Left(ValidationFailure(
          'Insufficient funds. Required: \$${(totalRequiredCents / 100).toStringAsFixed(2)}, Available: \$${(currentBalance / 100).toStringAsFixed(2)}',
        ));
      }

      final newBalance = currentBalance - totalRequiredCents;
      await localDataSource.updateBalanceCents(newBalance);

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
