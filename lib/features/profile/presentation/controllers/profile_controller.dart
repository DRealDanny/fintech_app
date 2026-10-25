import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSourceImpl();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final ds = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(ds);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return GetProfileUseCase(repo);
});

final toggleBiometricsUseCaseProvider =
    Provider<ToggleBiometricsUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ToggleBiometricsUseCase(repo);
});

final toggleNotificationsUseCaseProvider =
    Provider<ToggleNotificationsUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ToggleNotificationsUseCase(repo);
});

final upgradeTierUseCaseProvider = Provider<UpgradeTierUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return UpgradeTierUseCase(repo);
});

class ProfileState {
  final bool isLoading;
  final UserProfileEntity? profile;
  final String? errorMessage;
  final String? statusMessage;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.statusMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfileEntity? profile,
    String? errorMessage,
    String? statusMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      statusMessage: statusMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final ToggleBiometricsUseCase _toggleBiometricsUseCase;
  final ToggleNotificationsUseCase _toggleNotificationsUseCase;
  final UpgradeTierUseCase _upgradeTierUseCase;

  ProfileNotifier(
    this._getProfileUseCase,
    this._toggleBiometricsUseCase,
    this._toggleNotificationsUseCase,
    this._upgradeTierUseCase,
  ) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _getProfileUseCase();
    res.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
      ),
    );
  }

  Future<void> setBiometrics(bool enabled) async {
    final res = await _toggleBiometricsUseCase(enabled);
    res.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (profile) => state = state.copyWith(
        profile: profile,
        statusMessage: enabled ? 'Biometrics activated' : 'Biometrics disabled',
      ),
    );
  }

  Future<void> setNotifications(bool enabled) async {
    final res = await _toggleNotificationsUseCase(enabled);
    res.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (profile) => state = state.copyWith(
        profile: profile,
        statusMessage:
            enabled ? 'Notifications enabled' : 'Notifications muted',
      ),
    );
  }

  Future<void> upgradeToVip() async {
    final res = await _upgradeTierUseCase(UserTier.tier3Vip);
    res.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (profile) => state = state.copyWith(
        profile: profile,
        statusMessage: 'Upgraded to Tier 3 VIP!',
      ),
    );
  }

  Future<void> logout() async {
    await HiveStorage.setIsLoggedIn(false);
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final getP = ref.watch(getProfileUseCaseProvider);
  final toggleBio = ref.watch(toggleBiometricsUseCaseProvider);
  final toggleNotif = ref.watch(toggleNotificationsUseCaseProvider);
  final upTier = ref.watch(upgradeTierUseCaseProvider);

  return ProfileNotifier(getP, toggleBio, toggleNotif, upTier);
});
