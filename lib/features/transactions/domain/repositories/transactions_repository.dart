import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transaction_entity.dart';

/// Contract defining transaction data operations.
/// Pure Dart (Zero Flutter imports).
abstract class TransactionsRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? query,
    TransactionCategory? category,
  });

  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
}
