import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateBiometrics(bool enabled);
  Future<UserProfileEntity> updateNotifications(bool enabled);
  Future<UserProfileEntity> updateTier(UserTier tier);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  UserProfileEntity _currentProfile = const UserProfileEntity(
    fullName: 'Danny Adebayo',
    email: 'danny@nova.finance',
    phone: '+1 (555) 019-2834',
    novaTag: '\$danny.nova',
    tier: UserTier.tier2Verified,
    dailyLimitDollars: 25000,
    isBiometricEnabled: true,
    pushNotificationsEnabled: true,
    twoFactorEnabled: true,
  );

  @override
  Future<UserProfileEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentProfile;
  }

  @override
  Future<UserProfileEntity> updateBiometrics(bool enabled) async {
    _currentProfile = _currentProfile.copyWith(isBiometricEnabled: enabled);
    return _currentProfile;
  }

  @override
  Future<UserProfileEntity> updateNotifications(bool enabled) async {
    _currentProfile = _currentProfile.copyWith(pushNotificationsEnabled: enabled);
    return _currentProfile;
  }

  @override
  Future<UserProfileEntity> updateTier(UserTier tier) async {
    final limit = tier == UserTier.tier3Vip ? 100000 : 25000;
    _currentProfile = _currentProfile.copyWith(
      tier: tier,
      dailyLimitDollars: limit,
    );
    return _currentProfile;
  }
}
