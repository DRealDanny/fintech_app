import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

/// Central Type-Safe Navigation Router for Nova Fintech.
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: OnboardingRoute.page, initial: true),
        AutoRoute(page: PhoneInputRoute.page),
        AutoRoute(page: OtpVerificationRoute.page),
        AutoRoute(page: SetPinRoute.page),
        AutoRoute(page: BiometricSetupRoute.page),
        AutoRoute(page: DashboardRoute.page),
      ];
}
