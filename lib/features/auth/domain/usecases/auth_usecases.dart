import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_auth_session.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;
  const SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}

class VerifyOtpUseCase {
  final AuthRepository repository;
  const VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserAuthSession>> call(String phoneNumber, String otp) {
    return repository.verifyOtp(phoneNumber, otp);
  }
}

class SaveSecurityPinUseCase {
  final AuthRepository repository;
  const SaveSecurityPinUseCase(this.repository);

  Future<Either<Failure, bool>> call(String pin) {
    return repository.saveSecurityPin(pin);
  }
}

class VerifySecurityPinUseCase {
  final AuthRepository repository;
  const VerifySecurityPinUseCase(this.repository);

  Future<Either<Failure, bool>> call(String pin) {
    return repository.verifySecurityPin(pin);
  }
}

class AuthenticateBiometricsUseCase {
  final AuthRepository repository;
  const AuthenticateBiometricsUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.authenticateWithBiometrics();
  }
}

class CheckBiometricAvailabilityUseCase {
  final AuthRepository repository;
  const CheckBiometricAvailabilityUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.isBiometricAvailable();
  }
}

class GetActiveSessionUseCase {
  final AuthRepository repository;
  const GetActiveSessionUseCase(this.repository);

  Future<Either<Failure, UserAuthSession?>> call() {
    return repository.getActiveSession();
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
