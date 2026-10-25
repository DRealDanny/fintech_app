import '../../domain/entities/transaction_entity.dart';

abstract class TransactionsLocalDataSource {
  Future<List<TransactionEntity>> getTransactions({
    String? query,
    TransactionCategory? category,
  });

  Future<TransactionEntity?> getTransactionById(String id);
}

class TransactionsLocalDataSourceImpl implements TransactionsLocalDataSource {
  final List<TransactionEntity> _mockTransactions = [
    TransactionEntity(
      id: 'tx-001',
      title: 'Stripe Payout',
      subtitle: 'Client Contract #8821',
      amountCents: 425000,
      type: TransactionType.credit,
      category: TransactionCategory.salary,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      referenceNumber: 'STR-99281',
      counterparty: 'Stripe Inc.',
    ),
    TransactionEntity(
      id: 'tx-002',
      title: 'Sarah Connor',
      subtitle: 'Nova Instant Transfer',
      amountCents: 25000,
      type: TransactionType.debit,
      category: TransactionCategory.transfer,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      referenceNumber: 'TRX-779248',
      counterparty: 'Sarah Connor',
    ),
    TransactionEntity(
      id: 'tx-003',
      title: 'Apple Services',
      subtitle: 'iCloud+ 2TB & Apple Music',
      amountCents: 1499,
      type: TransactionType.debit,
      category: TransactionCategory.entertainment,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      referenceNumber: 'APL-11029',
      counterparty: 'Apple Inc.',
    ),
    TransactionEntity(
      id: 'tx-004',
      title: 'Amazon Web Services',
      subtitle: 'Cloud Infrastructure Hosting',
      amountCents: 18450,
      type: TransactionType.debit,
      category: TransactionCategory.bills,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      referenceNumber: 'AWS-44912',
      counterparty: 'Amazon AWS',
    ),
    TransactionEntity(
      id: 'tx-005',
      title: 'Starbucks Reserve',
      subtitle: 'Espresso & Breakfast Bagel',
      amountCents: 745,
      type: TransactionType.debit,
      category: TransactionCategory.dining,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      referenceNumber: 'SBX-00182',
      counterparty: 'Starbucks Store #44',
    ),
    TransactionEntity(
      id: 'tx-006',
      title: 'Tesla Supercharger',
      subtitle: 'Clean Energy Top-Up (48 kWh)',
      amountCents: 1980,
      type: TransactionType.debit,
      category: TransactionCategory.bills,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      referenceNumber: 'TSL-99812',
      counterparty: 'Tesla Inc.',
    ),
    TransactionEntity(
      id: 'tx-007',
      title: 'Dividend Yield',
      subtitle: 'Vanguard Total Stock ETF',
      amountCents: 8520,
      type: TransactionType.credit,
      category: TransactionCategory.salary,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      referenceNumber: 'VNG-33411',
      counterparty: 'Vanguard Group',
    ),
    TransactionEntity(
      id: 'tx-008',
      title: 'Netflix Premium UHD',
      subtitle: 'Monthly Family Subscription',
      amountCents: 2299,
      type: TransactionType.debit,
      category: TransactionCategory.entertainment,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      referenceNumber: 'NFLX-8812',
      counterparty: 'Netflix',
    ),
    TransactionEntity(
      id: 'tx-009',
      title: 'Whole Foods Market',
      subtitle: 'Organic Groceries',
      amountCents: 8940,
      type: TransactionType.debit,
      category: TransactionCategory.shopping,
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      referenceNumber: 'WFM-22991',
      counterparty: 'Whole Foods',
    ),
  ];

  @override
  Future<List<TransactionEntity>> getTransactions({
    String? query,
    TransactionCategory? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulating fast local access
    var list = List<TransactionEntity>.from(_mockTransactions);

    if (category != null && category != TransactionCategory.all) {
      list = list.where((tx) => tx.category == category).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((tx) {
        return tx.title.toLowerCase().contains(q) ||
            tx.subtitle.toLowerCase().contains(q) ||
            tx.referenceNumber.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    try {
      return _mockTransactions.firstWhere((tx) => tx.id == id);
    } catch (_) {
      return null;
    }
  }
}
