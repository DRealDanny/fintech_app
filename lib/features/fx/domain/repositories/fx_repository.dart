import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/currency_pocket_entity.dart';

abstract class FxRepository {
  Future<Either<Failure, List<CurrencyPocketEntity>>> getPockets();

  Future<Either<Failure, FxSwapReceipt>> swapCurrency({
    required String fromCode,
    required String toCode,
    required int fromAmountCents,
  });
}
