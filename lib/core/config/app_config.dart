/// Konfigurasi Global & Integrasi API JAVARA
///
/// Seluruh kredensial API eksternal (FASHN AI, Supabase, LLM) dibaca secara aman
/// melalui environment variables compile-time (`--dart-define`), tidak pernah
/// ditulis langsung (hardcoded) dalam kode sumber sesuai standar keamanan OWASP.
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

  /// Gemini API Key untuk AI Cultural Fashion Assistant (Abdi Pakar Busana)
  /// Jalankan dengan: `flutter run --dart-define=GEMINI_API_KEY=your_gemini_key`
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// LLM API Key (alias kompatibilitas)
  /// Jalankan dengan: `flutter run --dart-define=LLM_API_KEY=your_llm_key`
  static const String _llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  /// Model Google Gemini yang digunakan (default: 'gemini-1.5-pro')
  /// Jalankan dengan: `flutter run --dart-define=GEMINI_MODEL=gemini-1.5-pro`
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-1.5-pro',
  );

  /// Kredensial aktif untuk Google Gemini Pro API
  /// Membaca LLM_API_KEY atau GEMINI_API_KEY
  static String get llmApiKey {
    if (_llmApiKey.trim().isNotEmpty) return _llmApiKey.trim();
    return geminiApiKey.trim();
  }

  /// Cek apakah kredensial FASHN AI telah dikonfigurasi
  static bool get isFashnConfigured => fashnApiKey.trim().isNotEmpty;

  /// Cek apakah kredensial Supabase telah dikonfigurasi
  static bool get isSupabaseConfigured =>
      supabaseAnonKey.trim().isNotEmpty && supabaseUrl.trim().isNotEmpty;

  /// Cek apakah kredensial LLM Assistant (Gemini Pro) telah dikonfigurasi
  static bool get isLlmConfigured => llmApiKey.isNotEmpty;
}
