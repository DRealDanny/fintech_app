import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transactions_controller.dart';

@RoutePage()
class TransactionsHistoryScreen extends ConsumerStatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  ConsumerState<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState
    extends ConsumerState<TransactionsHistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTransactionDetails(
      BuildContext context, TransactionEntity tx) {
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
      isScrollControlled: true,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: surf,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tx.isCredit
                            ? AppColors.positiveGreen.withValues(alpha: 0.5)
                            : border,
                      ),
                    ),
                    child: Icon(
                      tx.isCredit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: tx.isCredit
                          ? AppColors.positiveGreen
                          : text,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    tx.title,
                    style: TextStyle(
                      color: text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    tx.subtitle,
                    style: TextStyle(
                      color: textSub,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '${tx.isCredit ? '+' : '-'}${currencyFmt.format(tx.amountDollars)}',
                    style: TextStyle(
                      color: tx.isCredit
                          ? AppColors.positiveGreen
                          : text,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surf,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Status', 'Completed', text, textSub,
                          valueColor: AppColors.positiveGreen),
                      Divider(color: border, height: 20),
                      _buildReceiptRow(
                          'Date & Time', dateFmt.format(tx.timestamp), text, textSub),
                      Divider(color: border, height: 20),
                      _buildReceiptRow(
                          'Reference Code', tx.referenceNumber, text, textSub,
                          isMonospace: true),
                      if (tx.counterparty != null) ...[
                        Divider(
                            color: border, height: 20),
                        _buildReceiptRow('Counterparty', tx.counterparty!, text, textSub),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: surfElevated,
                          content: Text(
                            '📄 Exporting PDF statement for ${tx.referenceNumber}...',
                            style: TextStyle(color: text),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.download_rounded,
                        color: onBtn),
                    label: const Text('Download Official Statement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn,
                      foregroundColor: onBtn,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

  Widget _buildReceiptRow(String label, String value, Color text, Color textSub,
      {Color? valueColor, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textSub,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? text,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            fontFamily: isMonospace ? 'Courier' : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    final currencyFmt = NumberFormat.currency(symbol: '\$');

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
          'Transactions',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined,
                color: text, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: surfElevated,
                  content: Text(
                    '📑 Generated All Statements (October 2026)',
                    style: TextStyle(color: text),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: text, fontSize: 14),
                onChanged: (val) {
                  ref
                      .read(transactionsControllerProvider.notifier)
                      .setSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search by merchant, note, or reference...',
                  hintStyle:
                      TextStyle(color: textSub, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: textSub, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: textSub, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(transactionsControllerProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: surf,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: text, width: 1.2),
                  ),
                ),
              ),
            ),

            // Inflow / Outflow Summary Banner (Green / Red)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded,
                                  color: AppColors.positiveGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'TOTAL INFLOW',
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+${currencyFmt.format(state.totalInflowCents / 100.0)}',
                            style: const TextStyle(
                              color: AppColors.positiveGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surf,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward_rounded,
                                  color: AppColors.negativeRed, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'TOTAL OUTFLOW',
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '-${currencyFmt.format(state.totalOutflowCents / 100.0)}',
                            style: const TextStyle(
                              color: AppColors.negativeRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Pills
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All', TransactionCategory.all, state, context),
                  _buildFilterChip(
                      'Transfers', TransactionCategory.transfer, state, context),
                  _buildFilterChip(
                      'Income', TransactionCategory.salary, state, context),
                  _buildFilterChip(
                      'Bills', TransactionCategory.bills, state, context),
                  _buildFilterChip(
                      'Shopping', TransactionCategory.shopping, state, context),
                  _buildFilterChip(
                      'Dining', TransactionCategory.dining, state, context),
                  _buildFilterChip('Entertainment',
                      TransactionCategory.entertainment, state, context),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions List
            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: text),
                    )
                  : state.transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 54, color: textSub),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = state.transactions[index];
                            final dateFmt = DateFormat('MMM dd, yyyy');

                            return InkWell(
                              onTap: () =>
                                  _showTransactionDetails(context, tx),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surf,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: surfElevated,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: tx.isCredit
                                              ? AppColors.positiveGreen
                                                  .withValues(alpha: 0.3)
                                              : border,
                                        ),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(tx.category),
                                        color: tx.isCredit
                                            ? AppColors.positiveGreen
                                            : text,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
                                            style: TextStyle(
                                              color: text,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${dateFmt.format(tx.timestamp)} • ${tx.subtitle}',
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
                                      '${tx.isCredit ? '+' : '-'}${currencyFmt.format(tx.amountDollars)}',
                                      style: TextStyle(
                                        color: tx.isCredit
                                            ? AppColors.positiveGreen
                                            : text,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, TransactionCategory category, TransactionsState state, BuildContext context) {
    final isSelected = state.selectedCategory == category;
    final isDark = AppColors.isDarkMode(context);
    final surf = AppColors.surf(context);
    final border = AppColors.border(context);
    final textSub = AppColors.textSub(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref
              .read(transactionsControllerProvider.notifier)
              .setCategory(category);
        },
        backgroundColor: surf,
        selectedColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        labelStyle: TextStyle(
          color: isSelected
              ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
              : textSub,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                : border,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  IconData _getCategoryIcon(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionCategory.salary:
        return Icons.arrow_downward_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.dining:
        return Icons.coffee_rounded;
      case TransactionCategory.entertainment:
        return Icons.movie_outlined;
      default:
        return Icons.payment_rounded;
    }
  }
}
