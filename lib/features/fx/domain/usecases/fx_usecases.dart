import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/currency_pocket_entity.dart';
import '../repositories/fx_repository.dart';

class GetPocketsUseCase {
  final FxRepository repository;
  const GetPocketsUseCase(this.repository);

  Future<Either<Failure, List<CurrencyPocketEntity>>> call() {
    return repository.getPockets();
  }
}

class SwapCurrencyUseCase {
  final FxRepository repository;
  const SwapCurrencyUseCase(this.repository);

  Future<Either<Failure, FxSwapReceipt>> call({
    required String fromCode,
    required String toCode,
    required int fromAmountCents,
  }) {
    return repository.swapCurrency(
      fromCode: fromCode,
      toCode: toCode,
      fromAmountCents: fromAmountCents,
    );
  }
}
