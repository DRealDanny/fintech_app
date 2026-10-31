import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TransferRemoteDataSource {
  /// Fetches the user's current wallet balance directly from Supabase.
  Future<int> getWalletBalanceMinor({required String userId});

  /// Streams the real-time balance of the user's wallet while the app is active.
  Stream<int> streamWalletBalanceMinor({required String userId});

  /// Calls the atomic PostgreSQL RPC function `execute_p2p_transfer` with row-level locks.
  Future<Map<String, dynamic>> executeP2pTransfer({
    required String recipientId,
    required int amountMinor,
    required String reference,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final SupabaseClient? client;

  const TransferRemoteDataSourceImpl({required this.client});

  @override
  Future<int> getWalletBalanceMinor({required String userId}) async {
    final supabase = client;
    if (supabase == null) {
      throw const PostgrestException(message: 'Supabase client is not initialized');
    }

    final response = await supabase
        .from('wallets')
        .select('balance_minor')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return 0;
    }

    final balance = response['balance_minor'];
    if (balance is int) return balance;
    if (balance is num) return balance.toInt();
    return int.tryParse(balance.toString()) ?? 0;
  }

  @override
  Stream<int> streamWalletBalanceMinor({required String userId}) {
    final supabase = client;
    if (supabase == null) {
      return const Stream.empty();
    }

    return supabase
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((rows) {
          if (rows.isEmpty) return 0;
          final balance = rows.first['balance_minor'];
          if (balance is int) return balance;
          if (balance is num) return balance.toInt();
          return int.tryParse(balance.toString()) ?? 0;
        });
  }

  @override
  Future<Map<String, dynamic>> executeP2pTransfer({
    required String recipientId,
    required int amountMinor,
    required String reference,
  }) async {
    final supabase = client;
    if (supabase == null) {
      throw const PostgrestException(message: 'Supabase client is not initialized');
    }

    // Call atomic PostgreSQL RPC function per HYBRID_STACK_MASTER.md Section 1.3 & 2.3
    final response = await supabase.rpc('execute_p2p_transfer', params: {
      'p_recipient_id': recipientId,
      'p_amount_minor': amountMinor,
      'p_reference': reference,
    });

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {'status': 'success', 'data': response};
  }
}

