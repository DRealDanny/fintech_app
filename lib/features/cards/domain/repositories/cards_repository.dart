import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/card_entity.dart';

abstract class CardsRepository {
  Future<Either<Failure, List<CardEntity>>> getCards();
  Future<Either<Failure, CardEntity>> toggleFreeze(String cardId);
  Future<Either<Failure, CardEntity>> updateSpendingLimit(
      String cardId, double newLimit);
  Future<Either<Failure, CardEntity>> toggleOnlinePayments(String cardId);
  Future<Either<Failure, CardEntity>> toggleInternationalPayments(String cardId);
}
