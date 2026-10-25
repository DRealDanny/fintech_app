import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/currency_pocket_entity.dart';
import '../controllers/fx_controller.dart';

@RoutePage()
class FxExchangeScreen extends ConsumerStatefulWidget {
  const FxExchangeScreen({super.key});

  @override
  ConsumerState<FxExchangeScreen> createState() => _FxExchangeScreenState();
}

class _FxExchangeScreenState extends ConsumerState<FxExchangeScreen> {
  final TextEditingController _amountCtrl = TextEditingController(text: '100');

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _showSwapSuccessModal(
      BuildContext context, FxSwapReceipt receipt, FxState state) {
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
                  child: const Icon(Icons.sync_alt_rounded,
                      color: AppColors.positiveGreen, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  'Currency Exchange Complete',
                  style: TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Exchanged ${receipt.fromCode} to ${receipt.toCode}',
                  style: TextStyle(
                      color: textSub, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '-${(receipt.fromAmountCents / 100).toStringAsFixed(2)} ${receipt.fromCode}',
                      style: const TextStyle(
                        color: AppColors.negativeRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: textSub, size: 16),
                    ),
                    Text(
                      '+${(receipt.toAmountCents / 100).toStringAsFixed(2)} ${receipt.toCode}',
                      style: const TextStyle(
                        color: AppColors.positiveGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                      _buildReceiptRow(
                          'Exchange Rate',
                          '1 ${receipt.fromCode} = ${receipt.appliedRate.toStringAsFixed(4)} ${receipt.toCode}',
                          text,
                          textSub),
                      Divider(color: border, height: 16),
                      _buildReceiptRow(
                          'Transaction Ref', receipt.referenceNumber, text, textSub),
                      Divider(color: border, height: 16),
                      _buildReceiptRow(
                          'Settlement', 'Instant (Zero FX Fee)', text, textSub,
                          color: AppColors.positiveGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn,
                      foregroundColor: onBtn,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to Pockets'),
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
      {Color? color}) {
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
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fxControllerProvider);
    final currencyFmt = NumberFormat.currency(symbol: '');

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
          'Currency Pockets & FX',
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
              // Pocket Carousel Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Currency Pockets',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Multi-Asset',
                    style: TextStyle(
                      color: textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pockets Horizontal Scroll
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.pockets.length,
                  itemBuilder: (context, index) {
                    final pocket = state.pockets[index];
                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pocket.flagEmoji,
                                  style: const TextStyle(fontSize: 22)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: surfElevated,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: border),
                                ),
                                child: Text(
                                  pocket.code,
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pocket.symbol}${currencyFmt.format(pocket.balanceDollars)}',
                                style: TextStyle(
                                  color: text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pocket.name,
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Swap Calculator Section
              Text(
                'Instant FX Swapper',
                style: TextStyle(
                  color: text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // "You Pay" Card
              Container(
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
                        Text(
                          'You Pay',
                          style: TextStyle(
                              color: textSub, fontSize: 13),
                        ),
                        Text(
                          'Balance: ${state.fromPocket?.symbol ?? ''}${((state.fromPocket?.balanceCents ?? 0) / 100.0).toStringAsFixed(2)}',
                          style: TextStyle(
                              color: textSub, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: TextStyle(
                              color: text,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                            onChanged: (val) {
                              final d = double.tryParse(val) ?? 0.0;
                              ref
                                  .read(fxControllerProvider.notifier)
                                  .setSwapAmountCents((d * 100).round());
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        _buildCurrencyDropdown(
                          selected: state.fromCode,
                          onChanged: (code) {
                            if (code != null) {
                              ref
                                  .read(fxControllerProvider.notifier)
                                  .setFromCode(code);
                            }
                          },
                          state: state,
                          context: context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Center Swap Button
              Center(
                child: InkWell(
                  onTap: () {
                    ref.read(fxControllerProvider.notifier).invertSelection();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfElevated,
                      border: Border.all(
                          color: text, width: 1.2),
                    ),
                    child: Icon(Icons.swap_vert_rounded,
                        color: text, size: 24),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // "You Receive" Card
              Container(
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
                        Text(
                          'You Receive (Estimated)',
                          style: TextStyle(
                              color: textSub, fontSize: 13),
                        ),
                        Text(
                          'Balance: ${state.toPocket?.symbol ?? ''}${((state.toPocket?.balanceCents ?? 0) / 100.0).toStringAsFixed(2)}',
                          style: TextStyle(
                              color: textSub, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (state.estimatedToAmountCents / 100.0)
                                .toStringAsFixed(2),
                            style: const TextStyle(
                              color: AppColors.positiveGreen,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _buildCurrencyDropdown(
                          selected: state.toCode,
                          onChanged: (code) {
                            if (code != null) {
                              ref
                                  .read(fxControllerProvider.notifier)
                                  .setToCode(code);
                            }
                          },
                          state: state,
                          context: context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rate Ticker Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: AppColors.positiveGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Live Interbank Rate',
                          style: TextStyle(
                              color: textSub, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      '1 ${state.fromCode} = ${state.exchangeRate.toStringAsFixed(4)} ${state.toCode}',
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Swap Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSwapping
                      ? null
                      : () async {
                          final success = await ref
                              .read(fxControllerProvider.notifier)
                              .executeSwap();
                          if (!context.mounted) return;
                          if (success) {
                            final receipt =
                                ref.read(fxControllerProvider).lastReceipt;
                            if (receipt != null) {
                              _showSwapSuccessModal(context, receipt, state);
                            }
                          } else {
                            final err =
                                ref.read(fxControllerProvider).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: surfElevated,
                                content: Text(
                                  err ?? 'Swap failed',
                                  style: const TextStyle(
                                      color: AppColors.negativeRed),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btn,
                    foregroundColor: onBtn,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isSwapping
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: onBtn, strokeWidth: 2),
                        )
                      : Text(
                          'Convert ${state.fromCode} to ${state.toCode}',
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

  Widget _buildCurrencyDropdown({
    required String selected,
    required ValueChanged<String?> onChanged,
    required FxState state,
    required BuildContext context,
  }) {
    final surfElevated = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: surfElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: surfElevated,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: text, size: 18),
          items: state.pockets.map((p) {
            return DropdownMenuItem<String>(
              value: p.code,
              child: Row(
                children: [
                  Text(p.flagEmoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    p.code,
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
