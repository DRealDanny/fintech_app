import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/onboarding_slide.dart';

/// Interactive high-fidelity visual card for each onboarding slide.
class OnboardingCardWidget extends StatelessWidget {
  final OnboardingSlide slide;
  final int index;

  const OnboardingCardWidget({
    super.key,
    required this.slide,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Ambient glow in corner
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getSlideAccentColor(index).withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGraphic(context, index),
                  const SizedBox(height: 20),
                  // Badge pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSlideAccentColor(index).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getSlideAccentColor(index).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      slide.badgeText,
                      style: TextStyle(
                        color: _getSlideAccentColor(index),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSlideAccentColor(int idx) {
    switch (idx) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.accentCyan;
      case 2:
      default:
        return AppColors.accentIndigo;
    }
  }

  Widget _buildGraphic(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        return _buildVirtualCard();
      case 1:
        return _buildYieldAnalytics();
      case 2:
      default:
        return _buildSecurityVault();
    }
  }

  // Slide 1 Graphic: Holographic Metal Debit Card
  Widget _buildVirtualCard() {
    return Container(
      width: 280,
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Icon(
                Icons.contactless,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '•••• •••• •••• 8842',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BALANCE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '\$28,450.00',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 2 Graphic: Yield & Growth Chart
  Widget _buildYieldAnalytics() {
    return Container(
      width: 280,
      height: 175,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Total Interest Earned',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '+\$1,842.50',
                    style: TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 12, color: AppColors.accentCyan),
                    SizedBox(width: 2),
                    Text(
                      '5.2%',
                      style: TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(25, false),
              _buildBar(38, false),
              _buildBar(32, false),
              _buildBar(52, false),
              _buildBar(46, false),
              _buildBar(64, false),
              _buildBar(78, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isLatest) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: isLatest ? AppColors.accentCyan : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isLatest
            ? [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
    );
  }

  // Slide 3 Graphic: Bank Grade Security Vault
  Widget _buildSecurityVault() {
    return Container(
      width: 280,
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accentIndigo.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentIndigo.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.accentIndigo,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentIndigo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Color(0xFF818CF8),
              size: 42,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Biometric MPC Secured',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'AES-256 Cloud Vault',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
