import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/beneficiary_entity.dart';
import '../entities/transfer_entity.dart';

/// Abstract contract for Transfer operations.
abstract class TransferRepository {
  Future<Either<Failure, List<BeneficiaryEntity>>> getBeneficiaries();

  Future<Either<Failure, TransferEntity>> executeTransfer({
    required BeneficiaryEntity beneficiary,
    required int amountCents,
    required String note,
    required String pin,
  });

  Future<Either<Failure, int>> getWalletBalanceCents();
}
