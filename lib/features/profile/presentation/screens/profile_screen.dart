import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../controllers/profile_controller.dart';
import '../widgets/kyc_upload_bottom_sheet.dart';
import '../../../../core/theme/theme_controller.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showKycUploadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const KycUploadBottomSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final surfElevated = AppColors.surfElevated(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: surfElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Log Out',
            style: TextStyle(
                color: text, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to log out of Nova? You will need your phone number and OTP to log back in.',
            style: TextStyle(color: textSub, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel',
                  style: TextStyle(color: textSub)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ref.read(profileControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.router.replaceAll([const PhoneInputRoute()]);
                }
              },
              child: const Text('Log Out',
                  style: TextStyle(
                      color: AppColors.negativeRed,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.profile;
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final bg = AppColors.bg(context);
    final surf = AppColors.surf(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: text, size: 20),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          'Profile & Settings',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: profile == null
            ? Center(
                child: CircularProgressIndicator(color: text))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isDark
                                  ? AppColors.primaryGradient
                                  : const LinearGradient(
                                      colors: [Color(0xFF2C2C2E), Color(0xFF000000)],
                                    ),
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: AppColors.pureWhite,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.fullName,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.novaTag,
                                  style: TextStyle(
                                    color: textSub,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: profile.isKycPending
                                        ? AppColors.accentAmber
                                            .withValues(alpha: 0.15)
                                        : (profile.isKycApproved
                                            ? AppColors.positiveGreen
                                                .withValues(alpha: 0.15)
                                            : AppColors.textMuted
                                                .withValues(alpha: 0.15)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        profile.isKycPending
                                            ? Icons.hourglass_top_rounded
                                            : (profile.isKycApproved
                                                ? Icons.verified_rounded
                                                : Icons.shield_outlined),
                                        color: profile.isKycPending
                                            ? AppColors.accentAmber
                                            : (profile.isKycApproved
                                                ? AppColors.positiveGreen
                                                : textSub),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        profile.isKycPending
                                            ? 'KYC Under Review'
                                            : (profile.isKycApproved
                                                ? 'Verified Pro Member'
                                                : 'Tier 1 Unverified'),
                                        style: TextStyle(
                                          color: profile.isKycPending
                                              ? AppColors.accentAmber
                                              : (profile.isKycApproved
                                                  ? AppColors.positiveGreen
                                                  : textSub),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // KYC Tier Verification Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KYC VERIFICATION TIER',
                                    style: TextStyle(
                                      color: textSub,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.tierTitle,
                                    style: TextStyle(
                                      color: text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: surfElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: border),
                                ),
                                child: Text(
                                  'Daily: ${currencyFmt.format(profile.dailyLimitDollars)}',
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Step Indicator
                          Row(
                            children: [
                              _buildTierStep('Tier 1', true, text, border, surfElevated),
                              _buildTierDivider(true, border),
                              _buildTierStep(
                                  'Tier 2',
                                  profile.tier == UserTier.tier2Verified ||
                                      profile.tier == UserTier.tier3Vip,
                                  text,
                                  border,
                                  surfElevated),
                              _buildTierDivider(
                                  profile.tier == UserTier.tier3Vip, border),
                              _buildTierStep(
                                  'Tier 3', profile.tier == UserTier.tier3Vip, text, border, surfElevated),
                            ],
                          ),
                          if (profile.isKycPending) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accentAmber
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    color: AppColors.accentAmber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Identity document submitted to Supabase Vault. Compliance review is in progress.',
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (!profile.isKycApproved) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showKycUploadModal(context),
                                icon: const Icon(Icons.upload_file_rounded,
                                    size: 18),
                                label: const Text(
                                  'Verify Identity (Unlock Tier 2 • \$25,000/day)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.pureWhite
                                      : AppColors.pureBlack,
                                  foregroundColor: isDark
                                      ? AppColors.pureBlack
                                      : AppColors.pureWhite,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ] else if (profile.tier != UserTier.tier3Vip) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(profileControllerProvider.notifier)
                                      .upgradeToVip();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: text,
                                  side: BorderSide(color: text),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Upgrade to Unlimited VIP (Tier 3)',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Security & Preferences Settings
                    Text(
                      'Security & Preferences',
                      style: TextStyle(
                        color: text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            context: context,
                            icon: isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            title: 'Dark Theme Mode',
                            subtitle: isDark
                                ? 'Pitch black luxury appearance'
                                : 'Crisp high-contrast light appearance',
                            value: isDark,
                            onChanged: (val) {
                              ref
                                  .read(themeModeControllerProvider.notifier)
                                  .toggleTheme();
                            },
                          ),
                          Divider(
                              color: border, height: 1),
                          _buildSwitchTile(
                            context: context,
                            icon: Icons.fingerprint_rounded,
                            title: 'Biometric Quick Unlock',
                            subtitle:
                                'Use Face ID or Fingerprint on app resume',
                            value: profile.isBiometricEnabled,
                            onChanged: (val) {
                              ref
                                  .read(profileControllerProvider.notifier)
                                  .setBiometrics(val);
                            },
                          ),
                          Divider(
                              color: border, height: 1),
                          _buildSwitchTile(
                            context: context,
                            icon: Icons.notifications_active_outlined,
                            title: 'Transaction Notifications',
                            subtitle: 'Instant push alerts for all card events',
                            value: profile.pushNotificationsEnabled,
                            onChanged: (val) {
                              ref
                                  .read(profileControllerProvider.notifier)
                                  .setNotifications(val);
                            },
                          ),
                          Divider(
                              color: border, height: 1),
                          _buildNavTile(
                            context: context,
                            icon: Icons.pin_outlined,
                            title: 'Change Security PIN',
                            subtitle: 'Update your 4-digit transaction passcode',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: surfElevated,
                                  content: Text(
                                    '🔒 Enter current PIN (1234) to set a new passcode',
                                    style: TextStyle(color: text),
                                  ),
                                ),
                              );
                            },
                          ),
                          Divider(
                              color: border, height: 1),
                          _buildNavTile(
                            context: context,
                            icon: Icons.file_download_outlined,
                            title: 'Export Official Statements',
                            subtitle: 'Download tax-compliant PDF reports',
                            onTap: () {
                              context.router
                                  .push(const TransactionsHistoryRoute());
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.negativeRed, size: 20),
                        label: const Text(
                          'Log Out of Account',
                          style: TextStyle(
                            color: AppColors.negativeRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surf,
                          elevation: 0,
                          side: BorderSide(
                              color: border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTierStep(String label, bool isActive, Color textColor, Color borderColor, Color surfElevated) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.positiveGreen : surfElevated,
            border: Border.all(
              color:
                  isActive ? AppColors.positiveGreen : borderColor,
            ),
          ),
          child: Icon(
            isActive ? Icons.check_rounded : Icons.circle,
            size: 14,
            color: isActive ? AppColors.pureBlack : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? textColor : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTierDivider(bool isActive, Color borderColor) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        color: isActive ? AppColors.positiveGreen : borderColor,
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = AppColors.isDarkMode(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);
    final surfElevated = AppColors.surfElevated(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surfElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: text, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            activeTrackColor: isDark ? AppColors.surfaceBorderLight : AppColors.lightSurfaceBorderLight,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: surfElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);
    final surfElevated = AppColors.surfElevated(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surfElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: text, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: textSub, size: 14),
          ],
        ),
      ),
    );
  }
}
