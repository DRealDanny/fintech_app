import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/cards_repository.dart';
import '../datasources/cards_local_datasource.dart';

class CardsRepositoryImpl implements CardsRepository {
  final CardsLocalDataSource localDataSource;

  const CardsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CardEntity>>> getCards() async {
    try {
      final list = await localDataSource.getCards();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure('Failed to load cards: $e'));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> toggleFreeze(String cardId) async {
    try {
      final cards = await localDataSource.getCards();
      final card = cards.firstWhere(
        (c) => c.id == cardId,
        orElse: () => throw Exception('Card not found'),
      );
      final updated = card.copyWith(isFrozen: !card.isFrozen);
      await localDataSource.updateCard(updated);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> updateSpendingLimit(
      String cardId, double newLimit) async {
    try {
      final cards = await localDataSource.getCards();
      final card = cards.firstWhere(
        (c) => c.id == cardId,
        orElse: () => throw Exception('Card not found'),
      );
      final updated = card.copyWith(spendingLimitDollars: newLimit);
      await localDataSource.updateCard(updated);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> toggleOnlinePayments(String cardId) async {
    try {
      final cards = await localDataSource.getCards();
      final card = cards.firstWhere(
        (c) => c.id == cardId,
        orElse: () => throw Exception('Card not found'),
      );
      final updated =
          card.copyWith(isOnlinePaymentsEnabled: !card.isOnlinePaymentsEnabled);
      await localDataSource.updateCard(updated);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> toggleInternationalPayments(
      String cardId) async {
    try {
      final cards = await localDataSource.getCards();
      final card = cards.firstWhere(
        (c) => c.id == cardId,
        orElse: () => throw Exception('Card not found'),
      );
      final updated = card.copyWith(
          isInternationalPaymentsEnabled:
              !card.isInternationalPaymentsEnabled);
      await localDataSource.updateCard(updated);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
