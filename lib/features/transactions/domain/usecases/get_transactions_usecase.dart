import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transactions_repository.dart';

/// Single-purpose business use case to fetch filtered transactions.
/// Pure Dart (Zero Flutter imports).
class GetTransactionsUseCase {
  final TransactionsRepository repository;

  const GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    String? query,
    TransactionCategory? category,
  }) {
    return repository.getTransactions(
      query: query,
      category: category,
    );
  }
}
