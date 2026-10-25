import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/biller_entity.dart';
import '../repositories/bills_repository.dart';

class GetBillersUseCase {
  final BillsRepository repository;
  const GetBillersUseCase(this.repository);

  Future<Either<Failure, List<BillerEntity>>> call(BillerCategory category) {
    return repository.getBillers(category);
  }
}

class ValidateAccountUseCase {
  final BillsRepository repository;
  const ValidateAccountUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String billerId,
    required String accountNumber,
  }) {
    return repository.validateAccountNumber(
      billerId: billerId,
      accountNumber: accountNumber,
    );
  }
}

class PayBillUseCase {
  final BillsRepository repository;
  const PayBillUseCase(this.repository);

  Future<Either<Failure, BillPaymentReceipt>> call({
    required BillerEntity biller,
    required String accountNumber,
    required int amountCents,
    required String pin,
  }) {
    return repository.payBill(
      biller: biller,
      accountNumber: accountNumber,
      amountCents: amountCents,
      pin: pin,
    );
  }
}
