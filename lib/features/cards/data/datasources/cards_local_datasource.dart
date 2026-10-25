import '../../domain/entities/card_entity.dart';

abstract class CardsLocalDataSource {
  Future<List<CardEntity>> getCards();
  Future<CardEntity> updateCard(CardEntity card);
}

class CardsLocalDataSourceImpl implements CardsLocalDataSource {
  static final List<CardEntity> _cards = [
    const CardEntity(
      id: 'c_virtual_1',
      cardHolder: 'DANNY OKOYE',
      cardNumber: '4532891204898842',
      expiryDate: '09/29',
      cvv: '741',
      isFrozen: false,
      spendingLimitDollars: 5000.0,
      currentSpentDollars: 1842.50,
      isOnlinePaymentsEnabled: true,
      isInternationalPaymentsEnabled: true,
      cardType: 'virtual',
    ),
    const CardEntity(
      id: 'c_physical_1',
      cardHolder: 'DANNY OKOYE',
      cardNumber: '5399482109483319',
      expiryDate: '11/30',
      cvv: '392',
      isFrozen: false,
      spendingLimitDollars: 10000.0,
      currentSpentDollars: 3120.00,
      isOnlinePaymentsEnabled: true,
      isInternationalPaymentsEnabled: false,
      cardType: 'physical',
    ),
  ];

  @override
  Future<List<CardEntity>> getCards() async {
    return List.from(_cards);
  }

  @override
  Future<CardEntity> updateCard(CardEntity card) async {
    final idx = _cards.indexWhere((c) => c.id == card.id);
    if (idx != -1) {
      _cards[idx] = card;
    }
    return card;
  }
}
