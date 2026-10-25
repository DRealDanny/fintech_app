// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:auto_route/auto_route.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/set_pin_screen.dart';
import '../../features/auth/presentation/screens/biometric_setup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [PhoneInputScreen]
class PhoneInputRoute extends PageRouteInfo<void> {
  const PhoneInputRoute({List<PageRouteInfo>? children})
      : super(
          PhoneInputRoute.name,
          initialChildren: children,
        );

  static const String name = 'PhoneInputRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PhoneInputScreen();
    },
  );
}

/// generated route for
/// [OtpVerificationScreen]
class OtpVerificationRoute extends PageRouteInfo<void> {
  const OtpVerificationRoute({List<PageRouteInfo>? children})
      : super(
          OtpVerificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'OtpVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OtpVerificationScreen();
    },
  );
}

/// generated route for
/// [SetPinScreen]
class SetPinRoute extends PageRouteInfo<void> {
  const SetPinRoute({List<PageRouteInfo>? children})
      : super(
          SetPinRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetPinRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SetPinScreen();
    },
  );
}

/// generated route for
/// [BiometricSetupScreen]
class BiometricSetupRoute extends PageRouteInfo<void> {
  const BiometricSetupRoute({List<PageRouteInfo>? children})
      : super(
          BiometricSetupRoute.name,
          initialChildren: children,
        );

  static const String name = 'BiometricSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BiometricSetupScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}
