import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/onboarding_slide.dart';

/// State model for Onboarding presentation layer.
class OnboardingState {
  final int currentIndex;
  final List<OnboardingSlide> slides;
  final bool isCompleted;

  const OnboardingState({
    this.currentIndex = 0,
    required this.slides,
    this.isCompleted = false,
  });

  bool get isLastPage => currentIndex == slides.length - 1;

  OnboardingState copyWith({
    int? currentIndex,
    List<OnboardingSlide>? slides,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      slides: slides ?? this.slides,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Riverpod StateNotifier controlling Onboarding logic & navigation state.
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController()
      : super(
          const OnboardingState(
            slides: [
              OnboardingSlide(
                id: '1',
                category: 'GLOBAL TRANSFERS',
                title: 'Transfer Money Globally with ',
                highlightText: 'Zero Hidden Fees',
                description:
                    'Send and receive funds in 30+ currencies with real-time interbank exchange rates and instant settlements.',
                badgeText: '⚡ Instant Settlement',
              ),
              OnboardingSlide(
                id: '2',
                category: 'SMART WEALTH',
                title: 'Grow Your Savings with ',
                highlightText: 'Automated Yield',
                description:
                    'Put your spare cash to work. Earn up to 5.2% APY with daily compounded payouts and flexible liquidity.',
                badgeText: '📈 5.2% Daily APY',
              ),
              OnboardingSlide(
                id: '3',
                category: 'BANK-GRADE SECURITY',
                title: 'Protected by 256-Bit ',
                highlightText: 'Biometric Shield',
                description:
                    'Your funds are safeguarded with multi-party computation, hardware biometric locks, and FDIC-insured partners.',
                badgeText: '🛡️ Bank-Grade Security',
              ),
            ],
          ),
        );

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }

  Future<void> completeOnboarding() async {
    await HiveStorage.setHasCompletedOnboarding(true);
    state = state.copyWith(isCompleted: true);
  }
}

/// Riverpod provider exposing OnboardingController.
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});
