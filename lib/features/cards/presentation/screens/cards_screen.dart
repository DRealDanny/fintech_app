import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/card_entity.dart';
import '../controllers/cards_controller.dart';

@RoutePage()
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardsControllerProvider);
    final card = state.activeCard;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.router.maybePop(),
        ),
        title: const Text(
          'Card Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: card == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Type Selector Tabs (Virtual vs Physical)
                    Row(
                      children: List.generate(state.cards.length, (idx) {
                        final isSelected = state.selectedCardIndex == idx;
                        final currentType = state.cards[idx].cardType;
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(cardsControllerProvider.notifier)
                                  .selectCard(idx);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: idx == 0 ? 8.0 : 0.0,
                                  left: idx == 1 ? 8.0 : 0.0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  currentType == 'virtual'
                                      ? '⚡ Virtual Card'
                                      : '💳 Physical Card',
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF042018)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // 3D Flip Card Widget
                    GestureDetector(
                      onTap: () {
                        ref.read(cardsControllerProvider.notifier).toggleFlip();
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, animation) {
                          final rotateAnim = Tween(begin: pi, end: 0.0).animate(
                              CurvedAnimation(
                                  parent: animation, curve: Curves.easeInOut));
                          return AnimatedBuilder(
                            animation: rotateAnim,
                            builder: (context, _) {
                              final isBack = child.key == const ValueKey('card_back');
                              var value = rotateAnim.value;
                              if (isBack) {
                                value = value - pi;
                              }
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(value),
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                          );
                        },
                        child: state.isCardFlipped
                            ? _buildCardBack(card)
                            : _buildCardFront(card),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        '💡 Tap card to flip and reveal CVV',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Spending Limit Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Monthly Spending Limit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${card.spendingLimitDollars.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (card.currentSpentDollars /
                                    card.spendingLimitDollars)
                                .clamp(0.0, 1.0),
                            backgroundColor: AppColors.surfaceBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${card.currentSpentDollars.toStringAsFixed(2)} spent',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              Text(
                                '\$${(card.spendingLimitDollars - card.currentSpentDollars).toStringAsFixed(2)} remaining',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: card.spendingLimitDollars,
                            min: 1000.0,
                            max: 15000.0,
                            divisions: 14,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.surfaceBorder,
                            onChanged: (newVal) {
                              ref
                                  .read(cardsControllerProvider.notifier)
                                  .updateLimit(newVal);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Security & Usage Toggles
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.ac_unit_rounded,
                            iconColor: AppColors.accentCyan,
                            title: 'Freeze Card',
                            subtitle:
                                'Temporarily block all purchases and withdrawals',
                            value: card.isFrozen,
                            onChanged: (val) {
                              ref
                                  .read(cardsControllerProvider.notifier)
                                  .toggleFreeze();
                            },
                          ),
                          const Divider(
                              color: AppColors.surfaceBorder, height: 16),
                          _buildToggleTile(
                            icon: Icons.shopping_bag_outlined,
                            iconColor: AppColors.accentIndigo,
                            title: 'Online Payments',
                            subtitle:
                                'Allow web and e-commerce authorizations',
                            value: card.isOnlinePaymentsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(cardsControllerProvider.notifier)
                                  .toggleOnline();
                            },
                          ),
                          const Divider(
                              color: AppColors.surfaceBorder, height: 16),
                          _buildToggleTile(
                            icon: Icons.public_rounded,
                            iconColor: AppColors.accentAmber,
                            title: 'International Payments',
                            subtitle:
                                'Allow transactions outside your country',
                            value: card.isInternationalPaymentsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(cardsControllerProvider.notifier)
                                  .toggleInternational();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCardFront(CardEntity card) {
    return Container(
      key: const ValueKey('card_front'),
      width: double.infinity,
      height: 215,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: card.isFrozen
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: card.cardType == 'virtual'
                    ? const [Color(0xFF0D3227), Color(0xFF041913)]
                    : const [Color(0xFF1E1B4B), Color(0xFF0F0E2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: card.isFrozen
              ? AppColors.surfaceBorder
              : (card.cardType == 'virtual'
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.accentIndigo.withValues(alpha: 0.5)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: card.isFrozen
                ? Colors.transparent
                : (card.cardType == 'virtual'
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.accentIndigo.withValues(alpha: 0.15)),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.wifi_rounded,
                          color: Colors.white70, size: 22),
                    ],
                  ),
                  Text(
                    card.cardType == 'virtual' ? 'NOVA VIRTUAL' : 'NOVA BLACK',
                    style: TextStyle(
                      color: card.cardType == 'virtual'
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                card.maskedCardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARDHOLDER',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.cardHolder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.expiryDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (card.isFrozen)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentCyan),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit_rounded,
                        color: AppColors.accentCyan, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'CARD FROZEN',
                      style: TextStyle(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBack(CardEntity card) {
    return Transform.flip(
      flipX: true,
      child: Container(
        key: const ValueKey('card_back'),
        width: double.infinity,
        height: 215,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Magnetic strip
            Container(
              width: double.infinity,
              height: 42,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 36,
                      color: Colors.white12,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Text(
                        'Authorized Signature',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 36,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        card.cvv,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
              child: Text(
                'Nova Bank Global Inc. Valid only with authorized signature. If found, return to any branch.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
