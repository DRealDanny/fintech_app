import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  /// Sends an OTP via SMS/WhatsApp through Supabase Auth.
  Future<void> signInWithOtp({required String phoneNumber});

  /// Verifies the OTP token against Supabase Auth.
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String token,
  });

  /// Signs out of Supabase Auth.
  Future<void> signOut();

  /// Gets the currently authenticated Supabase user.
  User? get currentUser;

  /// Gets the current Supabase session.
  Session? get currentSession;

  /// Stream of Supabase Auth state changes.
  Stream<AuthState> get onAuthStateChange;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient? client;

  const AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> signInWithOtp({required String phoneNumber}) async {
    final supabase = client;
    if (supabase == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    await supabase.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String token,
  }) async {
    final supabase = client;
    if (supabase == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    return await supabase.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  @override
  Future<void> signOut() async {
    final supabase = client;
    if (supabase != null) {
      await supabase.auth.signOut();
    }
  }

  @override
  User? get currentUser => client?.auth.currentUser;

  @override
  Session? get currentSession => client?.auth.currentSession;

  @override
  Stream<AuthState> get onAuthStateChange =>
      client?.auth.onAuthStateChange ?? const Stream.empty();
}

