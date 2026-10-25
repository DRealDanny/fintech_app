import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../transfer/presentation/controllers/transfer_controller.dart';
import '../../../fx/presentation/controllers/fx_controller.dart';
import '../../../../core/theme/theme_controller.dart';

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isBalanceVisible = true;
  int _currentNavIndex = 0;

  void _showReceiveModal(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: border)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Receive Funds',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share your Nova Tag or QR code to receive payments instantly',
                  style: TextStyle(color: textSub, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.pureWhite : AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 150,
                    color: AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nova Tag: ',
                        style: TextStyle(color: textSub, fontSize: 13),
                      ),
                      Text(
                        '\$danny.nova',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.copy_rounded, color: text, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferControllerProvider);
    final fxState = ref.watch(fxControllerProvider);
    final availableDollars = transferState.balanceCents / 100.0;
    final currencyFmt = NumberFormat.currency(symbol: '\$');

    final isDark = AppColors.isDarkMode(context);
    final bg = AppColors.bg(context);
    final surf = AppColors.surf(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.router.push(const ProfileRoute()),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
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
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: textSub,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Danny 👋',
                              style: TextStyle(
                                color: text,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Light / Dark Mode Toggle Button
                      IconButton(
                        onPressed: () {
                          ref
                              .read(themeModeControllerProvider.notifier)
                              .toggleTheme();
                        },
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: text,
                          size: 24,
                        ),
                        tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => context.router.push(const ProfileRoute()),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surf,
                            shape: BoxShape.circle,
                            border: Border.all(color: border),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: text,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Total Balance Card (Dynamic Black/White Luxury with Hairline Border)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGrad(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: border,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0x33000000)
                          : const Color(0x0D000000),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL BALANCE',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                          child: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textSub,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isBalanceVisible
                          ? currencyFmt.format(availableDollars)
                          : '••••••••',
                      style: TextStyle(
                        color: text,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.positiveGreen
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up_rounded,
                                  color: AppColors.positiveGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '+\$1,842.50 (+5.2%)',
                                style: TextStyle(
                                  color: AppColors.positiveGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'this month',
                          style: TextStyle(color: textSub, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Action Grid (Send, Receive, Cards, Pay Bills, FX Swap, History)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionBtn(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Send',
                    onTap: () => context.router.push(const TransferRoute()),
                    surf: surf,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                  _buildQuickActionBtn(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Receive',
                    onTap: () => _showReceiveModal(context),
                    surf: surf,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                  _buildQuickActionBtn(
                    icon: Icons.credit_card_rounded,
                    label: 'Cards',
                    onTap: () => context.router.push(const CardsRoute()),
                    surf: surf,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                  _buildQuickActionBtn(
                    icon: Icons.receipt_long_rounded,
                    label: 'Pay Bills',
                    onTap: () => context.router.push(const BillPaymentRoute()),
                    surf: surf,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWideActionBtn(
                    icon: Icons.sync_alt_rounded,
                    label: 'FX Pockets & Swap',
                    sublabel: 'USD, EUR, GBP, JPY',
                    onTap: () => context.router.push(const FxExchangeRoute()),
                    surf: surf,
                    surfElevated: surfElevated,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                  const SizedBox(width: 12),
                  _buildWideActionBtn(
                    icon: Icons.history_rounded,
                    label: 'Transactions',
                    sublabel: 'Filter & Statements',
                    onTap: () =>
                        context.router.push(const TransactionsHistoryRoute()),
                    surf: surf,
                    surfElevated: surfElevated,
                    border: border,
                    text: text,
                    textSub: textSub,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Multi-Currency Pockets Sneak Peek
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Multi-Currency Pockets',
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.router.push(const FxExchangeRoute()),
                    child: Text(
                      'Manage FX',
                      style: TextStyle(
                        color: text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fxState.pockets.length,
                  itemBuilder: (context, index) {
                    final pocket = fxState.pockets[index];
                    return Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Text(pocket.flagEmoji,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  pocket.code,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pocket.symbol}${(pocket.balanceDollars).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: textSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        context.router.push(const TransactionsHistoryRoute()),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // If a recent transfer was made, show it dynamically
              if (transferState.lastReceipt != null)
                _buildTransactionTile(
                  icon: Icons.send_rounded,
                  title: transferState.lastReceipt!.recipientName,
                  subtitle:
                      'Nova Transfer • ${transferState.lastReceipt!.note}',
                  amount:
                      '-\$${transferState.lastReceipt!.amountDollars.toStringAsFixed(2)}',
                  isCredit: false,
                  highlight: true,
                  surf: surf,
                  surfElevated: surfElevated,
                  border: border,
                  text: text,
                  textSub: textSub,
                ),

              // Standard Recent Transactions
              _buildTransactionTile(
                icon: Icons.account_balance_rounded,
                title: 'Stripe Payout',
                subtitle: 'Contract Client #8821',
                amount: '+\$4,250.00',
                isCredit: true,
                surf: surf,
                surfElevated: surfElevated,
                border: border,
                text: text,
                textSub: textSub,
              ),
              _buildTransactionTile(
                icon: Icons.apple,
                title: 'Apple Services',
                subtitle: 'iCloud+ 2TB & Music',
                amount: '-\$14.99',
                isCredit: false,
                surf: surf,
                surfElevated: surfElevated,
                border: border,
                text: text,
                textSub: textSub,
              ),
              _buildTransactionTile(
                icon: Icons.electric_bolt_rounded,
                title: 'Tesla Powergrid',
                subtitle: 'Utility Electric Recharge',
                amount: '-\$50.00',
                isCredit: false,
                surf: surf,
                surfElevated: surfElevated,
                border: border,
                text: text,
                textSub: textSub,
              ),
              _buildTransactionTile(
                icon: Icons.coffee_rounded,
                title: 'Starbucks Reserve',
                subtitle: 'Espresso & Dining',
                amount: '-\$7.45',
                isCredit: false,
                surf: surf,
                surfElevated: surfElevated,
                border: border,
                text: text,
                textSub: textSub,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surf,
          border: Border(top: BorderSide(color: border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
            if (index == 1) {
              context.router.push(const CardsRoute());
            } else if (index == 2) {
              context.router.push(const TransactionsHistoryRoute());
            } else if (index == 3) {
              context.router.push(const ProfileRoute());
            }
          },
          backgroundColor: surf,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          unselectedItemColor: textSub,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_rounded),
              label: 'Cards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color surf,
    required Color border,
    required Color text,
    required Color textSub,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Icon(icon, color: text, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textSub,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideActionBtn({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    required Color surf,
    required Color surfElevated,
    required Color border,
    required Color text,
    required Color textSub,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: surfElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: text, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sublabel,
                      style: TextStyle(
                        color: textSub,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildTransactionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
    bool highlight = false,
    required Color surf,
    required Color surfElevated,
    required Color border,
    required Color text,
    required Color textSub,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? text : border,
          width: highlight ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCredit
                    ? AppColors.positiveGreen.withValues(alpha: 0.3)
                    : border,
              ),
            ),
            child: Icon(
              icon,
              color: isCredit ? AppColors.positiveGreen : text,
              size: 20,
            ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? AppColors.positiveGreen : text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
