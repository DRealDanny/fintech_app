import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Service managing Supabase initialization and client access.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initializes the Supabase SDK if credentials are provided.
  static Future<void> initialize() async {
    if (!AppEnv.isSupabaseConfigured) {
      debugPrint(
        '⚠️ [SupabaseService] Supabase credentials not set. '
        'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or AppEnv.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: AppEnv.supabaseUrl,
        publishableKey: AppEnv.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('✅ [SupabaseService] Connected to Supabase: ${AppEnv.supabaseUrl}');
    } catch (e) {
      debugPrint('❌ [SupabaseService] Initialization failed: $e');
    }
  }

  /// Global client getter
  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}

/// Riverpod provider for SupabaseClient dependency injection
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseService.isInitialized) {
    return null;
  }
  return SupabaseService.client;
});

