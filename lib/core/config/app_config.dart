/// Konfigurasi Global & Integrasi API JAVARA
///
/// Seluruh kredensial API eksternal (FASHN AI, Supabase, LLM) dibaca secara aman
/// melalui environment variables compile-time (`--dart-define`) atau konfigurasi
/// runtime pengguna yang disimpan secara lokal di perangkat, tidak pernah
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

  /// Gemini API Key untuk AI Cultural Fashion Assistant (Abdi Pakar Busana)
  /// Jalankan dengan: `flutter run --dart-define=GEMINI_API_KEY=your_gemini_key`
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// LLM API Key (alias kompatibilitas umum)
  /// Jalankan dengan: `flutter run --dart-define=LLM_API_KEY=your_llm_key`
  static const String _llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  /// Groq API Key (opsional, gratis & cepat dengan model Llama 3.3)
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  /// OpenRouter API Key (opsional, mendukung model `:free`)
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  /// OpenAI API Key (opsional)
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  /// Pollinations API Key (opsional untuk kuota tanpa jeda)
  static const String pollinationsApiKey = String.fromEnvironment(
    'POLLINATIONS_API_KEY',
    defaultValue: '',
  );

  /// Model Google Gemini yang digunakan (default aktif: 'gemini-2.5-flash')
  /// Jalankan dengan: `flutter run --dart-define=GEMINI_MODEL=gemini-2.5-flash`
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  /// Kredensial aktif compile-time untuk AI Assistant
  /// Membaca LLM_API_KEY, GEMINI_API_KEY, GROQ_API_KEY, OPENROUTER_API_KEY, OPENAI_API_KEY, atau POLLINATIONS_API_KEY.
  static String get llmApiKey {
    final candidates = [
      _llmApiKey,
      geminiApiKey,
      groqApiKey,
      openRouterApiKey,
      openAiApiKey,
      pollinationsApiKey,
    ];
    for (final candidate in candidates) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  /// Cek apakah kredensial FASHN AI telah dikonfigurasi
  static bool get isFashnConfigured => fashnApiKey.trim().isNotEmpty;

  /// Cek apakah kredensial Supabase telah dikonfigurasi
  static bool get isSupabaseConfigured =>
      supabaseAnonKey.trim().isNotEmpty && supabaseUrl.trim().isNotEmpty;

  /// Cek apakah kredensial LLM Assistant compile-time telah dikonfigurasi
  static bool get isLlmConfigured => llmApiKey.isNotEmpty;
}
