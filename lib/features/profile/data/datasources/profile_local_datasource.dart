import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateBiometrics(bool enabled);
  Future<UserProfileEntity> updateNotifications(bool enabled);
  Future<UserProfileEntity> updateTier(UserTier tier);
  Future<UserProfileEntity> updateKycStatus({
    required String status,
    String? docUrl,
    String? docType,
  });
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  UserProfileEntity _currentProfile = const UserProfileEntity(
    fullName: 'Danny Adebayo',
    email: 'danny@nova.finance',
    phone: '+234 801 234 5678',
    novaTag: '\$danny.nova',
    tier: UserTier.tier1Basic,
    dailyLimitDollars: 5000,
    isBiometricEnabled: true,
    pushNotificationsEnabled: true,
    twoFactorEnabled: true,
    kycStatus: 'none',
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
    _currentProfile =
        _currentProfile.copyWith(pushNotificationsEnabled: enabled);
    return _currentProfile;
  }

  @override
  Future<UserProfileEntity> updateTier(UserTier tier) async {
    final limit = tier == UserTier.tier3Vip
        ? 100000
        : (tier == UserTier.tier2Verified ? 25000 : 5000);
    _currentProfile = _currentProfile.copyWith(
      tier: tier,
      dailyLimitDollars: limit,
    );
    return _currentProfile;
  }

  @override
  Future<UserProfileEntity> updateKycStatus({
    required String status,
    String? docUrl,
    String? docType,
  }) async {
    final tier = status == 'approved'
        ? UserTier.tier2Verified
        : _currentProfile.tier;
    final limit = status == 'approved' ? 25000 : _currentProfile.dailyLimitDollars;

    _currentProfile = _currentProfile.copyWith(
      kycStatus: status,
      kycDocumentUrl: docUrl ?? _currentProfile.kycDocumentUrl,
      kycDocumentType: docType ?? _currentProfile.kycDocumentType,
      kycSubmittedAt: DateTime.now(),
      tier: tier,
      dailyLimitDollars: limit,
    );
    return _currentProfile;
  }
}
