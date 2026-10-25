import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/currency_pocket_entity.dart';
import '../../domain/repositories/fx_repository.dart';
import '../datasources/fx_local_datasource.dart';

class FxRepositoryImpl implements FxRepository {
  final FxLocalDataSource localDataSource;

  FxRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<CurrencyPocketEntity>>> getPockets() async {
    try {
      final pockets = await localDataSource.getPockets();
      return Right(pockets);
    } catch (e) {
      return Left(CacheFailure('Failed to load currency pockets: $e'));
    }
  }

  @override
  Future<Either<Failure, FxSwapReceipt>> swapCurrency({
    required String fromCode,
    required String toCode,
    required int fromAmountCents,
  }) async {
    try {
      final receipt = await localDataSource.swapCurrency(
        fromCode: fromCode,
        toCode: toCode,
        fromAmountCents: fromAmountCents,
      );
      return Right(receipt);
    } catch (e) {
      return Left(ValidationFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
