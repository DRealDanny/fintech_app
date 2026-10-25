import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/biller_entity.dart';
import '../../domain/repositories/bills_repository.dart';
import '../datasources/bills_local_datasource.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsLocalDataSource localDataSource;

  BillsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<BillerEntity>>> getBillers(BillerCategory category) async {
    try {
      final billers = await localDataSource.getBillers(category);
      return Right(billers);
    } catch (e) {
      return Left(CacheFailure('Failed to load billers: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> validateAccountNumber({
    required String billerId,
    required String accountNumber,
  }) async {
    try {
      final name = await localDataSource.validateAccountNumber(billerId, accountNumber);
      return Right(name);
    } catch (e) {
      return Left(ValidationFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, BillPaymentReceipt>> payBill({
    required BillerEntity biller,
    required String accountNumber,
    required int amountCents,
    required String pin,
  }) async {
    try {
      if (pin != '1234') {
        return const Left(ValidationFailure('Incorrect authorization PIN'));
      }
      final receipt = await localDataSource.payBill(
        biller: biller,
        accountNumber: accountNumber,
        amountCents: amountCents,
      );
      return Right(receipt);
    } catch (e) {
      return Left(CacheFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
