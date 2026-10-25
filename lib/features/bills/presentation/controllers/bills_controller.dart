import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../data/datasources/bills_local_datasource.dart';
import '../../data/repositories/bills_repository_impl.dart';
import '../../domain/entities/biller_entity.dart';
import '../../domain/repositories/bills_repository.dart';
import '../../domain/usecases/pay_bill_usecases.dart';

final billsLocalDataSourceProvider = Provider<BillsLocalDataSource>((ref) {
  return BillsLocalDataSourceImpl();
});

final billsRepositoryProvider = Provider<BillsRepository>((ref) {
  final ds = ref.watch(billsLocalDataSourceProvider);
  return BillsRepositoryImpl(ds);
});

final getBillersUseCaseProvider = Provider<GetBillersUseCase>((ref) {
  final repo = ref.watch(billsRepositoryProvider);
  return GetBillersUseCase(repo);
});

final validateAccountUseCaseProvider = Provider<ValidateAccountUseCase>((ref) {
  final repo = ref.watch(billsRepositoryProvider);
  return ValidateAccountUseCase(repo);
});

final payBillUseCaseProvider = Provider<PayBillUseCase>((ref) {
  final repo = ref.watch(billsRepositoryProvider);
  return PayBillUseCase(repo);
});

class BillsState {
  final bool isLoading;
  final BillerCategory selectedCategory;
  final List<BillerEntity> billers;
  final BillerEntity? selectedBiller;
  final String accountNumber;
  final String? verifiedCustomerName;
  final int selectedAmountCents;
  final bool isPaying;
  final BillPaymentReceipt? lastReceipt;
  final String? errorMessage;
  final int balanceCents;

  const BillsState({
    this.isLoading = false,
    this.selectedCategory = BillerCategory.electricity,
    this.billers = const [],
    this.selectedBiller,
    this.accountNumber = '',
    this.verifiedCustomerName,
    this.selectedAmountCents = 5000, // $50.00 default
    this.isPaying = false,
    this.lastReceipt,
    this.errorMessage,
    this.balanceCents = 2820000,
  });

  BillsState copyWith({
    bool? isLoading,
    BillerCategory? selectedCategory,
    List<BillerEntity>? billers,
    BillerEntity? selectedBiller,
    String? accountNumber,
    String? verifiedCustomerName,
    int? selectedAmountCents,
    bool? isPaying,
    BillPaymentReceipt? lastReceipt,
    String? errorMessage,
    int? balanceCents,
  }) {
    return BillsState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      billers: billers ?? this.billers,
      selectedBiller: selectedBiller ?? this.selectedBiller,
      accountNumber: accountNumber ?? this.accountNumber,
      verifiedCustomerName: verifiedCustomerName ?? this.verifiedCustomerName,
      selectedAmountCents: selectedAmountCents ?? this.selectedAmountCents,
      isPaying: isPaying ?? this.isPaying,
      lastReceipt: lastReceipt,
      errorMessage: errorMessage,
      balanceCents: balanceCents ?? this.balanceCents,
    );
  }
}

class BillsNotifier extends StateNotifier<BillsState> {
  final GetBillersUseCase _getBillersUseCase;
  final ValidateAccountUseCase _validateAccountUseCase;
  final PayBillUseCase _payBillUseCase;

  BillsNotifier(
    this._getBillersUseCase,
    this._validateAccountUseCase,
    this._payBillUseCase,
  ) : super(BillsState(balanceCents: HiveStorage.walletBalanceCents)) {
    loadBillers(state.selectedCategory);
  }

  Future<void> loadBillers(BillerCategory category) async {
    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      errorMessage: null,
      balanceCents: HiveStorage.walletBalanceCents,
    );

    final result = await _getBillersUseCase(category);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (billers) {
        state = state.copyWith(
          isLoading: false,
          billers: billers,
          selectedBiller: billers.isNotEmpty ? billers.first : null,
          accountNumber: '',
          verifiedCustomerName: null,
        );
      },
    );
  }

  void selectBiller(BillerEntity biller) {
    state = state.copyWith(
      selectedBiller: biller,
      accountNumber: '',
      verifiedCustomerName: null,
    );
  }

  Future<void> setAccountNumber(String number) async {
    state = state.copyWith(accountNumber: number, verifiedCustomerName: null);
    if (number.length >= 6 && state.selectedBiller != null) {
      final res = await _validateAccountUseCase(
        billerId: state.selectedBiller!.id,
        accountNumber: number,
      );
      res.fold(
        (_) => state = state.copyWith(verifiedCustomerName: null),
        (name) => state = state.copyWith(verifiedCustomerName: name),
      );
    }
  }

  void setAmountCents(int cents) {
    state = state.copyWith(selectedAmountCents: cents);
  }

  Future<bool> processPayment(String pin) async {
    if (state.selectedBiller == null || state.accountNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select a biller and account number');
      return false;
    }

    state = state.copyWith(isPaying: true, errorMessage: null);
    final result = await _payBillUseCase(
      biller: state.selectedBiller!,
      accountNumber: state.accountNumber,
      amountCents: state.selectedAmountCents,
      pin: pin,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isPaying: false, errorMessage: failure.message);
        return false;
      },
      (receipt) {
        state = state.copyWith(
          isPaying: false,
          lastReceipt: receipt,
          balanceCents: HiveStorage.walletBalanceCents,
        );
        return true;
      },
    );
  }
}

final billsControllerProvider =
    StateNotifierProvider<BillsNotifier, BillsState>((ref) {
  final getBillers = ref.watch(getBillersUseCaseProvider);
  final validateAcc = ref.watch(validateAccountUseCaseProvider);
  final payBill = ref.watch(payBillUseCaseProvider);

  return BillsNotifier(getBillers, validateAcc, payBill);
});
