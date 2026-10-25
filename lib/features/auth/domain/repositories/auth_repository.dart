import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_auth_session.dart';

/// Abstract Domain Repository contract defining Authentication operations.
/// Pure Dart (Zero Flutter imports).
abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  
  Future<Either<Failure, UserAuthSession>> verifyOtp(String phoneNumber, String otp);
  
  Future<Either<Failure, bool>> saveSecurityPin(String pin);
  
  Future<Either<Failure, bool>> verifySecurityPin(String pin);
  
  Future<Either<Failure, bool>> authenticateWithBiometrics();
  
  Future<Either<Failure, bool>> isBiometricAvailable();
  
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);
}
