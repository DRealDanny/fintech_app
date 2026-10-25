import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_local_datasource.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsLocalDataSource localDataSource;

  TransactionsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? query,
    TransactionCategory? category,
  }) async {
    try {
      final results = await localDataSource.getTransactions(
        query: query,
        category: category,
      );
      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Failed to load transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) async {
    try {
      final tx = await localDataSource.getTransactionById(id);
      if (tx != null) {
        return Right(tx);
      }
      return const Left(CacheFailure('Transaction not found'));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve transaction: $e'));
    }
  }
}
