/// Pure Dart Failure definitions for Clean Architecture error handling.
/// Zero Flutter imports.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server connection failed', super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local storage', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', super.code]);
}

class BiometricFailure extends Failure {
  const BiometricFailure([super.message = 'Biometric authentication was cancelled or not recognized', super.code]);
}
