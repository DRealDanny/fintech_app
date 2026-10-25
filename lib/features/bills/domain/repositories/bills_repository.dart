import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/biller_entity.dart';

abstract class BillsRepository {
  Future<Either<Failure, List<BillerEntity>>> getBillers(BillerCategory category);

  Future<Either<Failure, String>> validateAccountNumber({
    required String billerId,
    required String accountNumber,
  });

  Future<Either<Failure, BillPaymentReceipt>> payBill({
    required BillerEntity biller,
    required String accountNumber,
    required int amountCents,
    required String pin,
  });
}
