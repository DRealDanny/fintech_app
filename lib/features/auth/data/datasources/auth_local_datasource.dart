import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> savePin(String pin);
  Future<String?> getPin();
  Future<bool> authenticateBiometrics();
  Future<bool> canCheckBiometrics();
  Future<void> setBiometricsEnabled(bool enabled);
  Future<bool> isBiometricsEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;

  static const String _keyToken = 'auth_jwt_token';
  static const String _keyPin = 'auth_security_pin';
  static const String _keyBiometricEnabled = 'auth_biometric_enabled';

  const AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.localAuth,
  });

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _keyToken);
  }

  @override
  Future<void> savePin(String pin) async {
    await secureStorage.write(key: _keyPin, value: pin);
  }

  @override
  Future<String?> getPin() async {
    return await secureStorage.read(key: _keyPin);
  }

  @override
  Future<bool> canCheckBiometrics() async {
    final canCheck = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  @override
  Future<bool> authenticateBiometrics() async {
    return await localAuth.authenticate(
      localizedReason: 'Authenticate to access your Nova Fintech account',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    await secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    final value = await secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }
}
