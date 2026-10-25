// ignore_for_file: prefer_initializing_formals
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/transfer_local_datasource.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/usecases/transfer_usecases.dart';

final transferLocalDataSourceProvider = Provider<TransferLocalDataSource>((ref) {
  return TransferLocalDataSourceImpl(
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(
    localDataSource: ref.watch(transferLocalDataSourceProvider),
  );
});

final getBeneficiariesUseCaseProvider = Provider<GetBeneficiariesUseCase>((ref) {
  return GetBeneficiariesUseCase(ref.watch(transferRepositoryProvider));
});

final executeTransferUseCaseProvider = Provider<ExecuteTransferUseCase>((ref) {
  return ExecuteTransferUseCase(ref.watch(transferRepositoryProvider));
});

final getWalletBalanceUseCaseProvider = Provider<GetWalletBalanceUseCase>((ref) {
  return GetWalletBalanceUseCase(ref.watch(transferRepositoryProvider));
});

class TransferState {
  final bool isLoading;
  final String? errorMessage;
  final List<BeneficiaryEntity> beneficiaries;
  final BeneficiaryEntity? selectedBeneficiary;
  final String enteredAmount;
  final String note;
  final int balanceCents;
  final TransferEntity? lastReceipt;

  const TransferState({
    this.isLoading = false,
    this.errorMessage,
    this.beneficiaries = const [],
    this.selectedBeneficiary,
    this.enteredAmount = '',
    this.note = '',
    this.balanceCents = 2845000,
    this.lastReceipt,
  });

  int get amountCents {
    final parsed = double.tryParse(enteredAmount) ?? 0.0;
    return (parsed * 100).round();
  }

  TransferState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<BeneficiaryEntity>? beneficiaries,
    BeneficiaryEntity? selectedBeneficiary,
    String? enteredAmount,
    String? note,
    int? balanceCents,
    TransferEntity? lastReceipt,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      selectedBeneficiary: selectedBeneficiary ?? this.selectedBeneficiary,
      enteredAmount: enteredAmount ?? this.enteredAmount,
      note: note ?? this.note,
      balanceCents: balanceCents ?? this.balanceCents,
      lastReceipt: lastReceipt,
    );
  }
}

class TransferController extends StateNotifier<TransferState> {
  final GetBeneficiariesUseCase _getBeneficiariesUseCase;
  final ExecuteTransferUseCase _executeTransferUseCase;
  final GetWalletBalanceUseCase _getWalletBalanceUseCase;

  TransferController({
    required GetBeneficiariesUseCase getBeneficiariesUseCase,
    required ExecuteTransferUseCase executeTransferUseCase,
    required GetWalletBalanceUseCase getWalletBalanceUseCase,
  })  : _getBeneficiariesUseCase = getBeneficiariesUseCase,
        _executeTransferUseCase = executeTransferUseCase,
        _getWalletBalanceUseCase = getWalletBalanceUseCase,
        super(const TransferState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final balanceRes = await _getWalletBalanceUseCase();
    final benRes = await _getBeneficiariesUseCase();

    final balance = balanceRes.getOrElse((_) => 2845000);
    final beneficiaries = benRes.getOrElse((_) => []);

    state = state.copyWith(
      balanceCents: balance,
      beneficiaries: beneficiaries,
      selectedBeneficiary: beneficiaries.isNotEmpty ? beneficiaries.first : null,
    );
  }

  void selectBeneficiary(BeneficiaryEntity beneficiary) {
    state = state.copyWith(selectedBeneficiary: beneficiary, errorMessage: null);
  }

  void updateAmount(String amount) {
    state = state.copyWith(enteredAmount: amount, errorMessage: null);
  }

  void appendAmountKey(String key) {
    if (key == '.' && state.enteredAmount.contains('.')) return;
    if (state.enteredAmount.contains('.') &&
        state.enteredAmount.split('.')[1].length >= 2) {
      return;
    }
    state = state.copyWith(
      enteredAmount: '${state.enteredAmount}$key',
      errorMessage: null,
    );
  }

  void deleteAmountKey() {
    if (state.enteredAmount.isNotEmpty) {
      state = state.copyWith(
        enteredAmount:
            state.enteredAmount.substring(0, state.enteredAmount.length - 1),
        errorMessage: null,
      );
    }
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<bool> executeTransferWithPin(String pin) async {
    if (state.selectedBeneficiary == null) {
      state = state.copyWith(errorMessage: 'Please select a recipient');
      return false;
    }

    if (state.amountCents <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid amount');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _executeTransferUseCase(
      beneficiary: state.selectedBeneficiary!,
      amountCents: state.amountCents,
      note: state.note,
      pin: pin,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (receipt) {
        final newBalance = state.balanceCents - receipt.totalDeductionCents;
        state = state.copyWith(
          isLoading: false,
          balanceCents: newBalance,
          lastReceipt: receipt,
          enteredAmount: '',
          note: '',
        );
        return true;
      },
    );
  }
}

final transferControllerProvider =
    StateNotifierProvider<TransferController, TransferState>((ref) {
  return TransferController(
    getBeneficiariesUseCase: ref.watch(getBeneficiariesUseCaseProvider),
    executeTransferUseCase: ref.watch(executeTransferUseCaseProvider),
    getWalletBalanceUseCase: ref.watch(getWalletBalanceUseCaseProvider),
  );
});
