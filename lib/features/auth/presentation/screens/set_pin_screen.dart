import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.gr.dart';
import '../controllers/auth_controller.dart';

@RoutePage()
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  void _onDigitTap(String digit) async {
    final controller = ref.read(authControllerProvider.notifier);
    controller.appendPinDigit(digit);

    final currentPin = ref.read(authControllerProvider).pinCode;
    if (currentPin.length == 4) {
      final success = await controller.savePin();
      if (mounted && success) {
        context.router.push(const BiometricSetupRoute());
      }
    }
  }

  void _onDelete() {
    ref.read(authControllerProvider.notifier).deletePinDigit();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentIndigo.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF818CF8),
                  size: 26,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Create Security PIN',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Set a 4-digit PIN for instant authorizations, transfers, and app unlocks.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // 4 PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < authState.pinCode.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: isFilled ? 18 : 16,
                    height: isFilled ? 18 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.primary : AppColors.surfaceBorder,
                        width: 2,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Custom Numeric Keypad
              Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['', '0', 'delete']),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        if (key == 'delete') {
          return InkWell(
            onTap: _onDelete,
            borderRadius: BorderRadius.circular(36),
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_outlined,
                color: Colors.white70,
                size: 26,
              ),
            ),
          );
        }
        return InkWell(
          onTap: () => _onDigitTap(key),
          borderRadius: BorderRadius.circular(36),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.surfaceBorder,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
