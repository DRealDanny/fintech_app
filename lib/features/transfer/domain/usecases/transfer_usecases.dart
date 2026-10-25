import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/beneficiary_entity.dart';
import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';

class GetBeneficiariesUseCase {
  final TransferRepository repository;
  const GetBeneficiariesUseCase(this.repository);

  Future<Either<Failure, List<BeneficiaryEntity>>> call() {
    return repository.getBeneficiaries();
  }
}

class ExecuteTransferUseCase {
  final TransferRepository repository;
  const ExecuteTransferUseCase(this.repository);

  Future<Either<Failure, TransferEntity>> call({
    required BeneficiaryEntity beneficiary,
    required int amountCents,
    required String note,
    required String pin,
  }) {
    return repository.executeTransfer(
      beneficiary: beneficiary,
      amountCents: amountCents,
      note: note,
      pin: pin,
    );
  }
}

class GetWalletBalanceUseCase {
  final TransferRepository repository;
  const GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getWalletBalanceCents();
  }
}
