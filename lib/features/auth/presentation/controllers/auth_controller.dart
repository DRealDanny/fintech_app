// ignore_for_file: prefer_initializing_formals
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/services/supabase_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// --- Dependency Injection via Riverpod Providers ---

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    secureStorage: ref.watch(secureStorageProvider),
    localAuth: ref.watch(localAuthProvider),
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AuthRemoteDataSourceImpl(client: client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final saveSecurityPinUseCaseProvider = Provider<SaveSecurityPinUseCase>((ref) {
  return SaveSecurityPinUseCase(ref.watch(authRepositoryProvider));
});

final verifySecurityPinUseCaseProvider =
    Provider<VerifySecurityPinUseCase>((ref) {
  return VerifySecurityPinUseCase(ref.watch(authRepositoryProvider));
});

final authenticateBiometricsUseCaseProvider =
    Provider<AuthenticateBiometricsUseCase>((ref) {
  return AuthenticateBiometricsUseCase(ref.watch(authRepositoryProvider));
});

final checkBiometricAvailabilityUseCaseProvider =
    Provider<CheckBiometricAvailabilityUseCase>((ref) {
  return CheckBiometricAvailabilityUseCase(ref.watch(authRepositoryProvider));
});

final getActiveSessionUseCaseProvider =
    Provider<GetActiveSessionUseCase>((ref) {
  return GetActiveSessionUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// --- Presentation State & Controller ---

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String phoneNumber;
  final String countryCode;
  final String otpCode;
  final String pinCode;
  final bool isBiometricAvailable;
  final UserAuthSession? session;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.phoneNumber = '',
    this.countryCode = '+234',
    this.otpCode = '',
    this.pinCode = '',
    this.isBiometricAvailable = false,
    this.session,
  });

  String get fullPhoneNumber {
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    // Remove national prefix 0 (e.g. 080... -> 80...)
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    return '$countryCode$cleanPhone';
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? phoneNumber,
    String? countryCode,
    String? otpCode,
    String? pinCode,
    bool? isBiometricAvailable,
    UserAuthSession? session,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      otpCode: otpCode ?? this.otpCode,
      pinCode: pinCode ?? this.pinCode,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      session: session ?? this.session,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SaveSecurityPinUseCase _savePinUseCase;
  final VerifySecurityPinUseCase _verifySecurityPinUseCase;
  final AuthenticateBiometricsUseCase _authBiometricsUseCase;
  final CheckBiometricAvailabilityUseCase _checkBioAvailabilityUseCase;
  final GetActiveSessionUseCase _getActiveSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthController({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required SaveSecurityPinUseCase savePinUseCase,
    required VerifySecurityPinUseCase verifySecurityPinUseCase,
    required AuthenticateBiometricsUseCase authBiometricsUseCase,
    required CheckBiometricAvailabilityUseCase checkBioAvailabilityUseCase,
    required GetActiveSessionUseCase getActiveSessionUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _savePinUseCase = savePinUseCase,
        _verifySecurityPinUseCase = verifySecurityPinUseCase,
        _authBiometricsUseCase = authBiometricsUseCase,
        _checkBioAvailabilityUseCase = checkBioAvailabilityUseCase,
        _getActiveSessionUseCase = getActiveSessionUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthState()) {
    checkBiometrics();
    loadActiveSession();
  }

  void updatePhoneNumber(String number) {
    state = state.copyWith(phoneNumber: number, errorMessage: null);
  }

  void updateCountryCode(String code) {
    state = state.copyWith(countryCode: code);
  }

  void updateOtp(String code) {
    state = state.copyWith(otpCode: code, errorMessage: null);
  }

  void appendPinDigit(String digit) {
    if (state.pinCode.length < 4) {
      state = state.copyWith(pinCode: '${state.pinCode}$digit', errorMessage: null);
    }
  }

  void deletePinDigit() {
    if (state.pinCode.isNotEmpty) {
      state = state.copyWith(
        pinCode: state.pinCode.substring(0, state.pinCode.length - 1),
        errorMessage: null,
      );
    }
  }

  void clearPin() {
    state = state.copyWith(pinCode: '', errorMessage: null);
  }

  Future<void> loadActiveSession() async {
    final result = await _getActiveSessionUseCase();
    result.fold(
      (failure) => null,
      (session) {
        if (session != null) {
          state = state.copyWith(session: session);
        }
      },
    );
  }

  Future<bool> sendOtp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _sendOtpUseCase(state.fullPhoneNumber);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> verifyOtp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _verifyOtpUseCase(state.fullPhoneNumber, state.otpCode);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (session) async {
        await HiveStorage.setIsLoggedIn(true);
        state = state.copyWith(isLoading: false, session: session);
        return true;
      },
    );
  }

  Future<bool> savePin() async {
    if (state.pinCode.length != 4) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _savePinUseCase(state.pinCode);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (success) async {
        await HiveStorage.setIsLoggedIn(true);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> verifyQuickPin(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _verifySecurityPinUseCase(pin);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (isValid) {
        state = state.copyWith(isLoading: false);
        if (!isValid) {
          state = state.copyWith(errorMessage: 'Incorrect PIN. Please try again.');
        }
        return isValid;
      },
    );
  }

  Future<void> checkBiometrics() async {
    final result = await _checkBioAvailabilityUseCase();
    result.fold(
      (failure) => state = state.copyWith(isBiometricAvailable: false),
      (available) => state = state.copyWith(isBiometricAvailable: available),
    );
  }

  Future<bool> authenticateBiometrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authBiometricsUseCase();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    await HiveStorage.setIsLoggedIn(false);
    state = const AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    savePinUseCase: ref.watch(saveSecurityPinUseCaseProvider),
    verifySecurityPinUseCase: ref.watch(verifySecurityPinUseCaseProvider),
    authBiometricsUseCase: ref.watch(authenticateBiometricsUseCaseProvider),
    checkBioAvailabilityUseCase:
        ref.watch(checkBiometricAvailabilityUseCaseProvider),
    getActiveSessionUseCase: ref.watch(getActiveSessionUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});
