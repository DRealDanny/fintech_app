import 'package:hive_flutter/hive_flutter.dart';

/// Central Local Cache Storage using Hive.
/// Strictly uses integer cents for monetary balances to prevent precision loss.
class HiveStorage {
  HiveStorage._();

  static const String appSettingsBoxName = 'app_settings';
  static const String walletBoxName = 'wallet_cache';
  static const String transactionsBoxName = 'transactions_cache';
  static const String beneficiariesBoxName = 'beneficiaries_cache';
  static const String cardsBoxName = 'cards_cache';

  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyIsBiometricEnabled = 'is_biometric_enabled';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyWalletBalanceCents = 'wallet_balance_cents';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(appSettingsBoxName);
    await Hive.openBox(walletBoxName);
    await Hive.openBox(transactionsBoxName);
    await Hive.openBox(beneficiariesBoxName);
    await Hive.openBox(cardsBoxName);

    // Initialize default wallet balance if not set ($28,450.00 = 2,845,000 cents)
    final walletBox = Hive.box(walletBoxName);
    if (!walletBox.containsKey(keyWalletBalanceCents)) {
      await walletBox.put(keyWalletBalanceCents, 2845000);
    }
  }

  // --- App Settings & Session ---
  static Box get _settingsBox => Hive.box(appSettingsBoxName);
  static Box get _walletBox => Hive.box(walletBoxName);

  static bool get hasCompletedOnboarding {
    if (!Hive.isBoxOpen(appSettingsBoxName)) return false;
    return _settingsBox.get(keyHasCompletedOnboarding, defaultValue: false)
        as bool;
  }

  static Future<void> setHasCompletedOnboarding(bool value) async {
    if (Hive.isBoxOpen(appSettingsBoxName)) {
      await _settingsBox.put(keyHasCompletedOnboarding, value);
    }
  }

  static bool get isLoggedIn {
    if (!Hive.isBoxOpen(appSettingsBoxName)) return false;
    return _settingsBox.get(keyIsLoggedIn, defaultValue: false) as bool;
  }

  static Future<void> setIsLoggedIn(bool value) async {
    if (Hive.isBoxOpen(appSettingsBoxName)) {
      await _settingsBox.put(keyIsLoggedIn, value);
    }
  }

  static bool get isBiometricEnabled {
    if (!Hive.isBoxOpen(appSettingsBoxName)) return false;
    return _settingsBox.get(keyIsBiometricEnabled, defaultValue: false) as bool;
  }

  static Future<void> setIsBiometricEnabled(bool value) async {
    if (Hive.isBoxOpen(appSettingsBoxName)) {
      await _settingsBox.put(keyIsBiometricEnabled, value);
    }
  }

  static bool get isDarkMode {
    if (!Hive.isBoxOpen(appSettingsBoxName)) return true;
    return _settingsBox.get(keyIsDarkMode, defaultValue: true) as bool;
  }

  static Future<void> setIsDarkMode(bool value) async {
    if (Hive.isBoxOpen(appSettingsBoxName)) {
      await _settingsBox.put(keyIsDarkMode, value);
    }
  }

  // --- Monetary Balances (In Cents) ---
  static int get walletBalanceCents {
    if (!Hive.isBoxOpen(walletBoxName)) return 2845000;
    return _walletBox.get(keyWalletBalanceCents, defaultValue: 2845000) as int;
  }

  static Future<void> setWalletBalanceCents(int cents) async {
    if (Hive.isBoxOpen(walletBoxName)) {
      await _walletBox.put(keyWalletBalanceCents, cents);
    }
  }

  static Future<void> clearAll() async {
    await _settingsBox.clear();
    await _walletBox.clear();
  }
}
