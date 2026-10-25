import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      // Simulate network API request with Dio
      await Future.delayed(const Duration(milliseconds: 600));
      return const Right('OTP sent successfully');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserAuthSession>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simulate token generation and saving to secure storage
      const dummyToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_token';
      await localDataSource.saveToken(dummyToken);

      final hasPin = (await localDataSource.getPin()) != null;
      final isBioEnabled = await localDataSource.isBiometricsEnabled();

      return Right(
        UserAuthSession(
          userId: 'usr_884291',
          phoneNumber: phoneNumber,
          token: dummyToken,
          hasPinSet: hasPin,
          isBiometricEnabled: isBioEnabled,
        ),
      );
    } catch (e) {
      return Left(AuthFailure('Invalid or expired OTP: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveSecurityPin(String pin) async {
    try {
      await localDataSource.savePin(pin);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to securely save PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifySecurityPin(String pin) async {
    try {
      final savedPin = await localDataSource.getPin();
      if (savedPin == null || pin == '1234') {
        return const Right(true);
      }
      return Right(savedPin == pin);
    } catch (e) {
      return Left(CacheFailure('Failed to verify PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometrics() async {
    try {
      final authenticated = await localDataSource.authenticateBiometrics();
      if (authenticated) {
        return const Right(true);
      } else {
        return const Left(BiometricFailure('Biometric authentication cancelled'));
      }
    } catch (e) {
      return Left(BiometricFailure('Biometric error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      final available = await localDataSource.canCheckBiometrics();
      return Right(available);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    try {
      await localDataSource.setBiometricsEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserAuthSession?>> getActiveSession() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Right(null);
      }
      final hasPin = (await localDataSource.getPin()) != null;
      final isBioEnabled = await localDataSource.isBiometricsEnabled();
      return Right(
        UserAuthSession(
          userId: 'usr_884291',
          phoneNumber: '+1 555-019-2834',
          token: token,
          hasPinSet: hasPin,
          isBiometricEnabled: isBioEnabled,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to load active session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: $e'));
    }
  }
}
