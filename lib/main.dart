import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/router/app_router.gr.dart';
import 'core/storage/hive_storage.dart';

import 'core/theme/theme_controller.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage for local cache & session persistence
  await HiveStorage.init();

  runApp(
    const ProviderScope(
      child: FintechApp(),
    ),
  );
}

class FintechApp extends ConsumerStatefulWidget {
  const FintechApp({super.key});

  @override
  ConsumerState<FintechApp> createState() => _FintechAppState();
}

class _FintechAppState extends ConsumerState<FintechApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Biometric Lock: Protect app resume states using local_auth per AGENTS.md
    if (state == AppLifecycleState.resumed) {
      if (HiveStorage.isLoggedIn && HiveStorage.isBiometricEnabled) {
        final currentPath = appRouter.current.name;
        // Don't duplicate if already on QuickUnlock or Splash
        if (currentPath != QuickUnlockRoute.name &&
            currentPath != SplashRoute.name) {
          appRouter.push(const QuickUnlockRoute());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Adjust system status bar icons based on active theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'Nova Fintech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter.config(),
    );
  }
}
