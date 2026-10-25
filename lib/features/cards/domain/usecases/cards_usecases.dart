import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/card_entity.dart';
import '../repositories/cards_repository.dart';

class GetCardsUseCase {
  final CardsRepository repository;
  const GetCardsUseCase(this.repository);

  Future<Either<Failure, List<CardEntity>>> call() {
    return repository.getCards();
  }
}

class ToggleFreezeCardUseCase {
  final CardsRepository repository;
  const ToggleFreezeCardUseCase(this.repository);

  Future<Either<Failure, CardEntity>> call(String cardId) {
    return repository.toggleFreeze(cardId);
  }
}

class UpdateSpendingLimitUseCase {
  final CardsRepository repository;
  const UpdateSpendingLimitUseCase(this.repository);

  Future<Either<Failure, CardEntity>> call(String cardId, double newLimit) {
    return repository.updateSpendingLimit(cardId, newLimit);
  }
}

class ToggleOnlinePaymentsUseCase {
  final CardsRepository repository;
  const ToggleOnlinePaymentsUseCase(this.repository);

  Future<Either<Failure, CardEntity>> call(String cardId) {
    return repository.toggleOnlinePayments(cardId);
  }
}

class ToggleInternationalPaymentsUseCase {
  final CardsRepository repository;
  const ToggleInternationalPaymentsUseCase(this.repository);

  Future<Either<Failure, CardEntity>> call(String cardId) {
    return repository.toggleInternationalPayments(cardId);
  }
}
