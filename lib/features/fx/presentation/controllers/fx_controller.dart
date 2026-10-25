import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/fx_local_datasource.dart';
import '../../data/repositories/fx_repository_impl.dart';
import '../../domain/entities/currency_pocket_entity.dart';
import '../../domain/repositories/fx_repository.dart';
import '../../domain/usecases/fx_usecases.dart';

final fxLocalDataSourceProvider = Provider<FxLocalDataSource>((ref) {
  return FxLocalDataSourceImpl();
});

final fxRepositoryProvider = Provider<FxRepository>((ref) {
  final ds = ref.watch(fxLocalDataSourceProvider);
  return FxRepositoryImpl(ds);
});

final getPocketsUseCaseProvider = Provider<GetPocketsUseCase>((ref) {
  final repo = ref.watch(fxRepositoryProvider);
  return GetPocketsUseCase(repo);
});

final swapCurrencyUseCaseProvider = Provider<SwapCurrencyUseCase>((ref) {
  final repo = ref.watch(fxRepositoryProvider);
  return SwapCurrencyUseCase(repo);
});

class FxState {
  final bool isLoading;
  final List<CurrencyPocketEntity> pockets;
  final String fromCode;
  final String toCode;
  final int swapAmountCents;
  final bool isSwapping;
  final FxSwapReceipt? lastReceipt;
  final String? errorMessage;

  const FxState({
    this.isLoading = false,
    this.pockets = const [],
    this.fromCode = 'USD',
    this.toCode = 'EUR',
    this.swapAmountCents = 10000, // $100.00
    this.isSwapping = false,
    this.lastReceipt,
    this.errorMessage,
  });

  CurrencyPocketEntity? get fromPocket =>
      pockets.cast<CurrencyPocketEntity?>().firstWhere(
            (p) => p?.code == fromCode,
            orElse: () => null,
          );

  CurrencyPocketEntity? get toPocket =>
      pockets.cast<CurrencyPocketEntity?>().firstWhere(
            (p) => p?.code == toCode,
            orElse: () => null,
          );

  double get exchangeRate {
    if (fromPocket == null || toPocket == null) return 1.0;
    return toPocket!.rateToUSD / fromPocket!.rateToUSD;
  }

  int get estimatedToAmountCents {
    return (swapAmountCents * exchangeRate).round();
  }

  FxState copyWith({
    bool? isLoading,
    List<CurrencyPocketEntity>? pockets,
    String? fromCode,
    String? toCode,
    int? swapAmountCents,
    bool? isSwapping,
    FxSwapReceipt? lastReceipt,
    String? errorMessage,
  }) {
    return FxState(
      isLoading: isLoading ?? this.isLoading,
      pockets: pockets ?? this.pockets,
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      swapAmountCents: swapAmountCents ?? this.swapAmountCents,
      isSwapping: isSwapping ?? this.isSwapping,
      lastReceipt: lastReceipt,
      errorMessage: errorMessage,
    );
  }
}

class FxNotifier extends StateNotifier<FxState> {
  final GetPocketsUseCase _getPocketsUseCase;
  final SwapCurrencyUseCase _swapCurrencyUseCase;

  FxNotifier(this._getPocketsUseCase, this._swapCurrencyUseCase)
      : super(const FxState()) {
    loadPockets();
  }

  Future<void> loadPockets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _getPocketsUseCase();
    res.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (pockets) => state = state.copyWith(
        isLoading: false,
        pockets: pockets,
      ),
    );
  }

  void setFromCode(String code) {
    if (code == state.toCode) {
      // Invert
      state = state.copyWith(fromCode: code, toCode: state.fromCode);
    } else {
      state = state.copyWith(fromCode: code);
    }
  }

  void setToCode(String code) {
    if (code == state.fromCode) {
      // Invert
      state = state.copyWith(toCode: code, fromCode: state.toCode);
    } else {
      state = state.copyWith(toCode: code);
    }
  }

  void invertSelection() {
    state = state.copyWith(fromCode: state.toCode, toCode: state.fromCode);
  }

  void setSwapAmountCents(int cents) {
    state = state.copyWith(swapAmountCents: cents);
  }

  Future<bool> executeSwap() async {
    state = state.copyWith(isSwapping: true, errorMessage: null);
    final res = await _swapCurrencyUseCase(
      fromCode: state.fromCode,
      toCode: state.toCode,
      fromAmountCents: state.swapAmountCents,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(isSwapping: false, errorMessage: failure.message);
        return false;
      },
      (receipt) async {
        await loadPockets();
        state = state.copyWith(
          isSwapping: false,
          lastReceipt: receipt,
        );
        return true;
      },
    );
  }
}

final fxControllerProvider =
    StateNotifierProvider<FxNotifier, FxState>((ref) {
  final getPockets = ref.watch(getPocketsUseCaseProvider);
  final swapCurrency = ref.watch(swapCurrencyUseCaseProvider);
  return FxNotifier(getPockets, swapCurrency);
});
