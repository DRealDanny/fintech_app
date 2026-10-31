/// Environment Configuration for the Fintech App.
/// 
/// Values can be injected at build/run time using:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Or configured via default values below.
class AppEnv {
  const AppEnv._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ohxsupxcadoufyhoijyt.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9oeHN1cHhjYWRvdWZ5aG9panl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMzNjM3ODksImV4cCI6MjEwODkzOTc4OX0.elx_ySPV5V-7Rk6LYNt1N0_jxOm0YPUd-rWpbQJ4mKo',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'https://placeholder.supabase.co';
}
