import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/router/app_router.gr.dart';
import 'core/storage/hive_storage.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage for local cache & session persistence
  await HiveStorage.init();

  // Set system UI overlay style for dark fintech aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090D16),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: FintechApp(),
    ),
  );
}

class FintechApp extends StatefulWidget {
  const FintechApp({super.key});

  @override
  State<FintechApp> createState() => _FintechAppState();
}

class _FintechAppState extends State<FintechApp> with WidgetsBindingObserver {
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
    return MaterialApp.router(
      title: 'Nova Fintech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter.config(),
    );
  }
}
