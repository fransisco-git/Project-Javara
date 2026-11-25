/// Konfigurasi Global & Integrasi API JAVARA
///
/// Seluruh kredensial API eksternal (FASHN AI, Supabase) dibaca secara aman
/// melalui environment variables compile-time (`--dart-define`), tidak pernah
/// ditulis langsung (hardcoded) dalam kode sumber.
class AppConfig {
  AppConfig._();

  /// FASHN AI API Key untuk Virtual Try-On
  /// Jalankan dengan: `flutter run --dart-define=FASHN_API_KEY=your_key_here`
  static const String fashnApiKey = String.fromEnvironment(
    'FASHN_API_KEY',
    defaultValue: '',
  );

  /// Base URL endpoint FASHN AI
  static const String fashnApiBaseUrl = 'https://api.fashn.ai/v1';

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

  /// Cek apakah kredensial FASHN AI telah dikonfigurasi
  static bool get isFashnConfigured => fashnApiKey.trim().isNotEmpty;

  /// Cek apakah kredensial Supabase telah dikonfigurasi
  static bool get isSupabaseConfigured =>
      supabaseAnonKey.trim().isNotEmpty && supabaseUrl.trim().isNotEmpty;
}
