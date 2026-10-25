import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

/// Central Type-Safe Navigation Router for Nova Fintech.
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: PhoneInputRoute.page),
        AutoRoute(page: OtpVerificationRoute.page),
        AutoRoute(page: SetPinRoute.page),
        AutoRoute(page: BiometricSetupRoute.page),
        AutoRoute(page: QuickUnlockRoute.page),
        AutoRoute(page: DashboardRoute.page),
        AutoRoute(page: TransferRoute.page),
        AutoRoute(page: CardsRoute.page),
        AutoRoute(page: TransactionsHistoryRoute.page),
        AutoRoute(page: BillPaymentRoute.page),
        AutoRoute(page: FxExchangeRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ];
}
