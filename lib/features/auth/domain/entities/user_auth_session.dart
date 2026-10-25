/// Pure Dart entity representing an authenticated user session.
/// Zero Flutter imports.
class UserAuthSession {
  final String userId;
  final String phoneNumber;
  final bool isBiometricEnabled;
  final bool hasPinSet;
  final String token;

  const UserAuthSession({
    required this.userId,
    required this.phoneNumber,
    this.isBiometricEnabled = false,
    this.hasPinSet = false,
    required this.token,
  });

  UserAuthSession copyWith({
    String? userId,
    String? phoneNumber,
    bool? isBiometricEnabled,
    bool? hasPinSet,
    String? token,
  }) {
    return UserAuthSession(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      hasPinSet: hasPinSet ?? this.hasPinSet,
      token: token ?? this.token,
    );
  }
}
