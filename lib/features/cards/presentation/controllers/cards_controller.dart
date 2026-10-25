// ignore_for_file: prefer_initializing_formals
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/cards_local_datasource.dart';
import '../../data/repositories/cards_repository_impl.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/cards_repository.dart';
import '../../domain/usecases/cards_usecases.dart';

final cardsLocalDataSourceProvider = Provider<CardsLocalDataSource>((ref) {
  return CardsLocalDataSourceImpl();
});

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepositoryImpl(
    localDataSource: ref.watch(cardsLocalDataSourceProvider),
  );
});

final getCardsUseCaseProvider = Provider<GetCardsUseCase>((ref) {
  return GetCardsUseCase(ref.watch(cardsRepositoryProvider));
});

final toggleFreezeCardUseCaseProvider =
    Provider<ToggleFreezeCardUseCase>((ref) {
  return ToggleFreezeCardUseCase(ref.watch(cardsRepositoryProvider));
});

final updateSpendingLimitUseCaseProvider =
    Provider<UpdateSpendingLimitUseCase>((ref) {
  return UpdateSpendingLimitUseCase(ref.watch(cardsRepositoryProvider));
});

final toggleOnlinePaymentsUseCaseProvider =
    Provider<ToggleOnlinePaymentsUseCase>((ref) {
  return ToggleOnlinePaymentsUseCase(ref.watch(cardsRepositoryProvider));
});

final toggleInternationalPaymentsUseCaseProvider =
    Provider<ToggleInternationalPaymentsUseCase>((ref) {
  return ToggleInternationalPaymentsUseCase(ref.watch(cardsRepositoryProvider));
});

class CardsState {
  final bool isLoading;
  final String? errorMessage;
  final List<CardEntity> cards;
  final int selectedCardIndex;
  final bool isCardFlipped;

  const CardsState({
    this.isLoading = false,
    this.errorMessage,
    this.cards = const [],
    this.selectedCardIndex = 0,
    this.isCardFlipped = false,
  });

  CardEntity? get activeCard =>
      cards.isNotEmpty && selectedCardIndex < cards.length
          ? cards[selectedCardIndex]
          : null;

  CardsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CardEntity>? cards,
    int? selectedCardIndex,
    bool? isCardFlipped,
  }) {
    return CardsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      cards: cards ?? this.cards,
      selectedCardIndex: selectedCardIndex ?? this.selectedCardIndex,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
    );
  }
}

class CardsController extends StateNotifier<CardsState> {
  final GetCardsUseCase _getCardsUseCase;
  final ToggleFreezeCardUseCase _toggleFreezeCardUseCase;
  final UpdateSpendingLimitUseCase _updateSpendingLimitUseCase;
  final ToggleOnlinePaymentsUseCase _toggleOnlinePaymentsUseCase;
  final ToggleInternationalPaymentsUseCase _toggleInternationalPaymentsUseCase;

  CardsController({
    required GetCardsUseCase getCardsUseCase,
    required ToggleFreezeCardUseCase toggleFreezeCardUseCase,
    required UpdateSpendingLimitUseCase updateSpendingLimitUseCase,
    required ToggleOnlinePaymentsUseCase toggleOnlinePaymentsUseCase,
    required ToggleInternationalPaymentsUseCase
        toggleInternationalPaymentsUseCase,
  })  : _getCardsUseCase = getCardsUseCase,
        _toggleFreezeCardUseCase = toggleFreezeCardUseCase,
        _updateSpendingLimitUseCase = updateSpendingLimitUseCase,
        _toggleOnlinePaymentsUseCase = toggleOnlinePaymentsUseCase,
        _toggleInternationalPaymentsUseCase =
            toggleInternationalPaymentsUseCase,
        super(const CardsState()) {
    loadCards();
  }

  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getCardsUseCase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (cards) => state = state.copyWith(isLoading: false, cards: cards),
    );
  }

  void selectCard(int index) {
    state = state.copyWith(selectedCardIndex: index, isCardFlipped: false);
  }

  void toggleFlip() {
    state = state.copyWith(isCardFlipped: !state.isCardFlipped);
  }

  Future<void> toggleFreeze() async {
    final card = state.activeCard;
    if (card == null) return;

    final result = await _toggleFreezeCardUseCase(card.id);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updatedCard) {
        final updatedList = List<CardEntity>.from(state.cards);
        updatedList[state.selectedCardIndex] = updatedCard;
        state = state.copyWith(cards: updatedList);
      },
    );
  }

  Future<void> updateLimit(double limit) async {
    final card = state.activeCard;
    if (card == null) return;

    final result = await _updateSpendingLimitUseCase(card.id, limit);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updatedCard) {
        final updatedList = List<CardEntity>.from(state.cards);
        updatedList[state.selectedCardIndex] = updatedCard;
        state = state.copyWith(cards: updatedList);
      },
    );
  }

  Future<void> toggleOnline() async {
    final card = state.activeCard;
    if (card == null) return;

    final result = await _toggleOnlinePaymentsUseCase(card.id);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updatedCard) {
        final updatedList = List<CardEntity>.from(state.cards);
        updatedList[state.selectedCardIndex] = updatedCard;
        state = state.copyWith(cards: updatedList);
      },
    );
  }

  Future<void> toggleInternational() async {
    final card = state.activeCard;
    if (card == null) return;

    final result = await _toggleInternationalPaymentsUseCase(card.id);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updatedCard) {
        final updatedList = List<CardEntity>.from(state.cards);
        updatedList[state.selectedCardIndex] = updatedCard;
        state = state.copyWith(cards: updatedList);
      },
    );
  }
}

final cardsControllerProvider =
    StateNotifierProvider<CardsController, CardsState>((ref) {
  return CardsController(
    getCardsUseCase: ref.watch(getCardsUseCaseProvider),
    toggleFreezeCardUseCase: ref.watch(toggleFreezeCardUseCaseProvider),
    updateSpendingLimitUseCase: ref.watch(updateSpendingLimitUseCaseProvider),
    toggleOnlinePaymentsUseCase: ref.watch(toggleOnlinePaymentsUseCaseProvider),
    toggleInternationalPaymentsUseCase:
        ref.watch(toggleInternationalPaymentsUseCaseProvider),
  );
});
