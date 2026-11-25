/// Konfigurasi Global & Integrasi API JAVARA
///
/// Seluruh kredensial API eksternal (Supabase) dibaca secara aman
/// melalui environment variables compile-time (`--dart-define`), tidak pernah
/// ditulis langsung (hardcoded) dalam kode sumber.
class AppConfig {
  AppConfig._();

  /// Supabase Project URL
  /// Jalankan dengan: `flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://javara-cultural-heritage.supabase.co',
  );

  /// Supabase Anon / Public Key
  /// Jalankan dengan: `flutter run --dart-define=SUPABASE_ANON_KEY=your_anon_key`
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Cek apakah kredensial Supabase telah dikonfigurasi
  static bool get isSupabaseConfigured =>
      supabaseAnonKey.trim().isNotEmpty && supabaseUrl.trim().isNotEmpty;
}
