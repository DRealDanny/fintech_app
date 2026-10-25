import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/biller_entity.dart';
import '../controllers/bills_controller.dart';

@RoutePage()
class BillPaymentScreen extends ConsumerStatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  ConsumerState<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends ConsumerState<BillPaymentScreen> {
  final TextEditingController _accountCtrl = TextEditingController();

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  void _showPinModal(BuildContext context) {
    String enteredPin = '';
    final surf = AppColors.surf(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Authorize Utility Payment',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your 4-digit PIN (Default: 1234)',
                      style: TextStyle(
                        color: textSub,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PIN Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final filled = index < enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? text
                                : Colors.transparent,
                            border: Border.all(
                              color: filled
                                  ? text
                                  : border,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Numeric Pad
                    for (int row = 0; row < 4; row++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (row < 3) ...[
                              for (int col = 1; col <= 3; col++)
                                _buildPadBtn(
                                  '${row * 3 + col}',
                                  () {
                                    if (enteredPin.length < 4) {
                                      setModalState(() {
                                        enteredPin += '${row * 3 + col}';
                                      });
                                      if (enteredPin.length == 4) {
                                        _executePayment(
                                            bottomSheetContext, enteredPin);
                                      }
                                    }
                                  },
                                  surf,
                                  border,
                                  text,
                                ),
                            ] else ...[
                              const SizedBox(width: 64, height: 64),
                              _buildPadBtn(
                                '0',
                                () {
                                  if (enteredPin.length < 4) {
                                    setModalState(() {
                                      enteredPin += '0';
                                    });
                                    if (enteredPin.length == 4) {
                                      _executePayment(
                                          bottomSheetContext, enteredPin);
                                    }
                                  }
                                },
                                surf,
                                border,
                                text,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (enteredPin.isNotEmpty) {
                                    setModalState(() {
                                      enteredPin = enteredPin.substring(
                                          0, enteredPin.length - 1);
                                    });
                                  }
                                },
                                icon: Icon(Icons.backspace_outlined,
                                    color: text),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPadBtn(String text, VoidCallback onTap, Color surf, Color border, Color textColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: surf,
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _executePayment(
      BuildContext modalContext, String pin) async {
    Navigator.pop(modalContext);

    final success = await ref
        .read(billsControllerProvider.notifier)
        .processPayment(pin);

    if (success && mounted) {
      final receipt = ref.read(billsControllerProvider).lastReceipt;
      if (receipt != null) {
        _showReceiptModal(context, receipt);
      }
    } else if (mounted) {
      final error = ref.read(billsControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfElevated(context),
          content: Text(
            error ?? 'Payment authorization failed',
            style: const TextStyle(color: AppColors.negativeRed),
          ),
        ),
      );
    }
  }

  void _showReceiptModal(BuildContext context, BillPaymentReceipt receipt) {
    final currencyFmt = NumberFormat.currency(symbol: '\$');
    final dateFmt = DateFormat('MMM dd, yyyy • hh:mm a');

    final surf = AppColors.surf(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);
    final btn = AppColors.btn(context);
    final onBtn = AppColors.onBtn(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.positiveGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.positiveGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.positiveGreen, size: 32),
                ),
                const SizedBox(height: 14),
                Text(
                  'Utility Bill Paid Successfully',
                  style: TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  receipt.billerName,
                  style: TextStyle(
                      color: textSub, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  currencyFmt.format(receipt.amountDollars),
                  style: TextStyle(
                    color: text,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surf,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Recharge Token', receipt.tokenCode, text, textSub,
                          isBold: true, color: AppColors.positiveGreen),
                      Divider(
                          color: border, height: 16),
                      _buildReceiptRow(
                          'Account/Meter', receipt.accountNumber, text, textSub),
                      Divider(
                          color: border, height: 16),
                      _buildReceiptRow(
                          'Reference', receipt.referenceNumber, text, textSub),
                      Divider(
                          color: border, height: 16),
                      _buildReceiptRow(
                          'Date', dateFmt.format(receipt.timestamp), text, textSub),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.router.maybePop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn,
                      foregroundColor: onBtn,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, Color text, Color textSub,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(color: textSub, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color ?? text,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsControllerProvider);
    final currencyFmt = NumberFormat.currency(symbol: '\$');

    final bg = AppColors.bg(context);
    final surf = AppColors.surf(context);
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);
    final btn = AppColors.btn(context);
    final onBtn = AppColors.onBtn(context);

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
          'Pay Bills & Top-Up',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WALLET BALANCE',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available for utilities',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFmt.format(state.balanceCents / 100.0),
                      style: TextStyle(
                        color: text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Row
              Text(
                'Select Utility Category',
                style: TextStyle(
                  color: text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCategoryTab(
                    icon: Icons.electric_bolt_rounded,
                    label: 'Power',
                    category: BillerCategory.electricity,
                    state: state,
                    context: context,
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryTab(
                    icon: Icons.phone_android_rounded,
                    label: 'Mobile',
                    category: BillerCategory.mobile,
                    state: state,
                    context: context,
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryTab(
                    icon: Icons.wifi_rounded,
                    label: 'Internet',
                    category: BillerCategory.internet,
                    state: state,
                    context: context,
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryTab(
                    icon: Icons.water_drop_rounded,
                    label: 'Water',
                    category: BillerCategory.water,
                    state: state,
                    context: context,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Service Providers
              Text(
                'Service Provider',
                style: TextStyle(
                  color: text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (state.isLoading)
                Center(
                    child: CircularProgressIndicator(color: text))
              else
                Column(
                  children: state.billers.map((biller) {
                    final isSelected = state.selectedBiller?.id == biller.id;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(billsControllerProvider.notifier)
                            .selectBiller(biller);
                        _accountCtrl.clear();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? surfElevated
                              : surf,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? text
                                : border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: surf,
                                border:
                                    Border.all(color: border),
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? text
                                    : textSub,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    biller.name,
                                    style: TextStyle(
                                      color: text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Code: ${biller.code}',
                                    style: TextStyle(
                                      color: textSub,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              // Account / Meter Input
              if (state.selectedBiller != null) ...[
                Text(
                  state.selectedBiller!.accountLabel,
                  style: TextStyle(
                    color: text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _accountCtrl,
                  keyboardType: TextInputType.number,
                  style:
                      TextStyle(color: text, fontSize: 15),
                  onChanged: (val) {
                    ref
                        .read(billsControllerProvider.notifier)
                        .setAccountNumber(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. 984729104',
                    hintStyle:
                        TextStyle(color: textSub, fontSize: 13),
                    filled: true,
                    fillColor: surf,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: text, width: 1.2),
                    ),
                  ),
                ),
                if (state.verifiedCustomerName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.positiveGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        state.verifiedCustomerName!,
                        style: const TextStyle(
                          color: AppColors.positiveGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Amount Selection Chips
              Text(
                'Top-Up Amount',
                style: TextStyle(
                  color: text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountChip(2000, '\$20', state, context),
                  _buildAmountChip(5000, '\$50', state, context),
                  _buildAmountChip(10000, '\$100', state, context),
                  _buildAmountChip(20000, '\$200', state, context),
                ],
              ),

              const SizedBox(height: 36),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.accountNumber.length >= 6
                      ? () => _showPinModal(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btn,
                    foregroundColor: onBtn,
                    disabledBackgroundColor: surf,
                    disabledForegroundColor: textSub,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Pay ${currencyFmt.format(state.selectedAmountCents / 100.0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required IconData icon,
    required String label,
    required BillerCategory category,
    required BillsState state,
    required BuildContext context,
  }) {
    final isSelected = state.selectedCategory == category;
    final isDark = AppColors.isDarkMode(context);
    final surf = AppColors.surf(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(billsControllerProvider.notifier).loadBillers(category);
          _accountCtrl.clear();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? AppColors.pureWhite : AppColors.pureBlack) : surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                  : border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? (isDark ? AppColors.pureBlack : AppColors.pureWhite) : text,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
                      : textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(int cents, String label, BillsState state, BuildContext context) {
    final isSelected = state.selectedAmountCents == cents;
    final isDark = AppColors.isDarkMode(context);
    final surf = AppColors.surf(context);
    final border = AppColors.border(context);

    return InkWell(
      onTap: () {
        ref.read(billsControllerProvider.notifier).setAmountCents(cents);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.pureWhite : AppColors.pureBlack) : surf,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                : border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? (isDark ? AppColors.pureBlack : AppColors.pureWhite) : AppColors.text(context),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
