import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transfer_entity.dart';
import '../controllers/transfer_controller.dart';

@RoutePage()
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    ref.read(transferControllerProvider.notifier).updateAmount(val);
  }

  void _setPresetAmount(double amount) {
    final str = amount.toStringAsFixed(0);
    _amountController.text = str;
    ref.read(transferControllerProvider.notifier).updateAmount(str);
  }

  void _showPinConfirmationModal(BuildContext context, TransferState state) {
    if (state.selectedBeneficiary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient first.')),
      );
      return;
    }
    if (state.amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount to transfer.')),
      );
      return;
    }

    String enteredPin = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirm Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sending \$${(state.amountCents / 100).toStringAsFixed(2)} to ${state.selectedBeneficiary!.name}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PIN Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (idx) {
                        final filled = idx < enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: filled
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Numeric Keypad
                    _buildModalKeypad(
                      onKeyTap: (digit) async {
                        if (enteredPin.length < 4) {
                          setModalState(() {
                            enteredPin += digit;
                          });

                          if (enteredPin.length == 4) {
                            final success = await ref
                                .read(transferControllerProvider.notifier)
                                .executeTransferWithPin(enteredPin);

                            if (context.mounted) {
                              Navigator.pop(context); // Close PIN modal
                              if (success) {
                                final updatedState =
                                    ref.read(transferControllerProvider);
                                if (updatedState.lastReceipt != null) {
                                  _showReceiptModal(
                                      context, updatedState.lastReceipt!);
                                }
                              } else {
                                final err = ref
                                    .read(transferControllerProvider)
                                    .errorMessage;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.surface,
                                    content: Text(
                                      err ?? 'Transfer authorization failed.',
                                      style: const TextStyle(
                                          color: AppColors.accentRose),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      onBackspace: () {
                        if (enteredPin.isNotEmpty) {
                          setModalState(() {
                            enteredPin = enteredPin.substring(
                                0, enteredPin.length - 1);
                          });
                        }
                      },
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

  void _showReceiptModal(BuildContext context, TransferEntity receipt) {
    final currencyFmt = NumberFormat.currency(symbol: '\$');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transfer Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Transaction Reference: ${receipt.referenceNumber}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Amount Sent',
                          currencyFmt.format(receipt.amountDollars),
                          isBold: true, color: AppColors.primary),
                      const Divider(color: AppColors.surfaceBorder, height: 20),
                      _buildReceiptRow('Recipient', receipt.recipientName),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Account', receipt.recipientAccount),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Fee', '\$0.00 (Nova Free Transfer)'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('Note', receipt.note),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx); // Close modal
                      context.router.maybePop(); // Return to dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF042018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModalKeypad({
    required Function(String) onKeyTap,
    required VoidCallback onBackspace,
  }) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], onKeyTap),
        const SizedBox(height: 12),
        _buildKeypadRow(['4', '5', '6'], onKeyTap),
        const SizedBox(height: 12),
        _buildKeypadRow(['7', '8', '9'], onKeyTap),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            _buildKeypadButton('0', onKeyTap),
            InkWell(
              onTap: onBackspace,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: const Icon(Icons.backspace_outlined,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> values, Function(String) onKeyTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => _buildKeypadButton(val, onKeyTap)).toList(),
    );
  }

  Widget _buildKeypadButton(String value, Function(String) onKeyTap) {
    return InkWell(
      onTap: () => onKeyTap(value),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferControllerProvider);
    final availableDollars = state.balanceCents / 100.0;

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
          'Send Money',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Indicator Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    Text(
                      '\$${availableDollars.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recipients Selector Header
              const Text(
                'Select Recipient',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal Beneficiaries List
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.beneficiaries.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 14),
                  itemBuilder: (context, idx) {
                    final ben = state.beneficiaries[idx];
                    final isSelected = state.selectedBeneficiary?.id == ben.id;

                    return InkWell(
                      onTap: () {
                        ref
                            .read(transferControllerProvider.notifier)
                            .selectBeneficiary(ben);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 76,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(ben.colorHex),
                              ),
                              child: Center(
                                child: Text(
                                  ben.avatarInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ben.name.split(' ').first,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Amount Entry Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Enter Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Amount Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [50.0, 100.0, 250.0, 500.0].map((amt) {
                        return InkWell(
                          onTap: () => _setPresetAmount(amt),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              '\$${amt.toInt()}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Note / Purpose Input
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'What\'s this for? (Optional note)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  prefixIcon: const Icon(Icons.edit_note_rounded,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                onChanged: (val) {
                  ref.read(transferControllerProvider.notifier).updateNote(val);
                },
              ),

              const SizedBox(height: 32),

              // Transfer Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showPinConfirmationModal(context, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF042018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Continue to Authorization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
