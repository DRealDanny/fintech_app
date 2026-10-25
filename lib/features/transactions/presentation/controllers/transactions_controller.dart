import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/transactions_local_datasource.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

final transactionsLocalDataSourceProvider =
    Provider<TransactionsLocalDataSource>((ref) {
  return TransactionsLocalDataSourceImpl();
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final ds = ref.watch(transactionsLocalDataSourceProvider);
  return TransactionsRepositoryImpl(ds);
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  return GetTransactionsUseCase(repo);
});

class TransactionsState {
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final TransactionCategory selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const TransactionsState({
    this.isLoading = false,
    this.transactions = const [],
    this.selectedCategory = TransactionCategory.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  TransactionsState copyWith({
    bool? isLoading,
    List<TransactionEntity>? transactions,
    TransactionCategory? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  int get totalInflowCents => transactions
      .where((tx) => tx.isCredit)
      .fold(0, (sum, tx) => sum + tx.amountCents);

  int get totalOutflowCents => transactions
      .where((tx) => !tx.isCredit)
      .fold(0, (sum, tx) => sum + tx.amountCents);
}

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionsNotifier(this._getTransactionsUseCase)
      : super(const TransactionsState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getTransactionsUseCase(
      query: state.searchQuery,
      category: state.selectedCategory,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        isLoading: false,
        transactions: data,
      ),
    );
  }

  void setCategory(TransactionCategory category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    loadTransactions();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadTransactions();
  }
}

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return TransactionsNotifier(useCase);
});
