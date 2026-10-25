enum UserTier {
  tier1Basic,
  tier2Verified,
  tier3Vip,
}

/// Pure Dart entity representing user profile, KYC tier, and app preferences.
class UserProfileEntity {
  final String fullName;
  final String email;
  final String phone;
  final String novaTag;
  final UserTier tier;
  final int dailyLimitDollars;
  final bool isBiometricEnabled;
  final bool pushNotificationsEnabled;
  final bool twoFactorEnabled;

  const UserProfileEntity({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.novaTag,
    required this.tier,
    required this.dailyLimitDollars,
    required this.isBiometricEnabled,
    required this.pushNotificationsEnabled,
    required this.twoFactorEnabled,
  });

  String get tierTitle {
    switch (tier) {
      case UserTier.tier1Basic:
        return 'Tier 1 • Basic';
      case UserTier.tier2Verified:
        return 'Tier 2 • Verified Pro';
      case UserTier.tier3Vip:
        return 'Tier 3 • Unlimited VIP';
    }
  }

  UserProfileEntity copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? novaTag,
    UserTier? tier,
    int? dailyLimitDollars,
    bool? isBiometricEnabled,
    bool? pushNotificationsEnabled,
    bool? twoFactorEnabled,
  }) {
    return UserProfileEntity(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      novaTag: novaTag ?? this.novaTag,
      tier: tier ?? this.tier,
      dailyLimitDollars: dailyLimitDollars ?? this.dailyLimitDollars,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}
