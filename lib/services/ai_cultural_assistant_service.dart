import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../features/fashion/models/javanese_clothing_models.dart';
import 'ai_cultural_knowledge_base.dart';

/// Jenis Pesan Asisten Budaya
enum AssistantRole { user, assistant, system }

/// Provider Mesin AI yang Didukung Asisten Budaya JAVARA
enum AiProviderMode {
  auto('Otomatis (Deteksi Key)', 'gemini-2.5-flash'),
  gemini('Google Gemini', 'gemini-2.5-flash'),
  groq('Groq AI (Gratis & Cepat)', 'llama-3.3-70b-versatile'),
  openRouter('OpenRouter AI (Gratis)', 'openrouter/free'),
  pollinations('Pollinations AI', 'openai-fast'),
  openAi('OpenAI ChatGPT', 'gpt-4o-mini');

  const AiProviderMode(this.label, this.defaultModel);
  final String label;
  final String defaultModel;
}

/// Hasil Pengujian Koneksi Live API AI
class AiConnectionTestResult {
  const AiConnectionTestResult({
    required this.ok,
    required this.message,
    required this.provider,
    this.model,
  });

  final bool ok;
  final String message;
  final AiProviderMode provider;
  final String? model;
}

/// Aksi Interaktif yang Dihasilkan Fungsi AI (Function Calling)
class AssistantAction {
  const AssistantAction({
    required this.type,
    required this.title,
    required this.description,
    this.targetOutfit,
    this.targetGarment,
  });

  final String type; // 'outfit_recommendation', 'garment_detail', 'batik_motif'
  final String title;
  final String description;
  final TraditionalOutfit? targetOutfit;
  final ClothingItem? targetGarment;
}

/// Model Pesan Percakapan Asisten AI JAVARA
class AssistantChatMessage {
  const AssistantChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.action,
    this.sourceReference,
  });

  final String id;
  final AssistantRole role;
  final String text;
  final DateTime timestamp;
  final AssistantAction? action;
  final String? sourceReference;
}

/// Layanan Asisten Cerdas Busana Adat Jawa Tengah (Grounded Cultural AI Assistant)
///
/// Mendukung:
/// 1. Kredensial pengguna (Google Gemini, Groq, OpenRouter, OpenAI, Pollinations) via runtime UI
///    (`SharedPreferences`) maupun compile-time (`--dart-define`).
/// 2. Auto-discovery model Gemini aktif bila model lama mengembalikan HTTP 404.
/// 3. Gateway AI Publik gratis tanpa API Key (Pollinations `openai-fast`) yang di-grounding dengan
///    konteks RAG busana JAVARA agar langsung aktif keluar kotak (*out-of-the-box*).
/// 4. Pencarian Wikipedia Indonesia & Pustaka Budaya JAVARA sebagai fallback tangguh tanpa crash.
class AiCulturalAssistantService {
  AiCulturalAssistantService({
    this.httpClient,
    this.apiKey,
    this.model,
    AiProviderMode? provider,
    String? systemPrompt,
    this.requestTimeout = const Duration(seconds: 12),
    this.enablePublicAiFallback = true,
  })  : _explicitProvider = provider,
        _customSystemPrompt = systemPrompt;

  /// Singleton instance default untuk aplikasi
  static AiCulturalAssistantService instance = AiCulturalAssistantService();

  static const String _prefKeyApiKey = 'javara_ai_runtime_api_key';
  static const String _prefKeyProvider = 'javara_ai_runtime_provider';
  static const String _prefKeyModel = 'javara_ai_runtime_model';

  static const Map<String, String> _wikiHeaders = {
    'User-Agent': 'JavaraApp/1.0 (https://javara.app; contact@javara.app) Flutter',
    'Accept': 'application/json',
  };

  final http.Client? httpClient;
  final String? apiKey;
  final String? model;
  final AiProviderMode? _explicitProvider;
  final String? _customSystemPrompt;
  final Duration requestTimeout;
  final bool enablePublicAiFallback;

  final List<AssistantChatMessage> _sessionHistory = [];

  bool _runtimeLoaded = false;
  String _runtimeApiKey = '';
  AiProviderMode _runtimeProvider = AiProviderMode.auto;
  String _runtimeModel = '';
  String? _discoveredGeminiModel;
  DateTime? _publicCooldownUntil;

  /// Riwayat percakapan sesi aktif
  List<AssistantChatMessage> get sessionHistory =>
      List.unmodifiable(_sessionHistory);

  /// Menghapus riwayat percakapan sesi
  void clearSession() {
    _sessionHistory.clear();
  }

  /// Memuat konfigurasi runtime pengguna dari SharedPreferences (idempoten & aman di unit test).
  Future<void> initialize({bool force = false}) async {
    if (_runtimeLoaded && !force) return;
    _runtimeLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _runtimeApiKey = (prefs.getString(_prefKeyApiKey) ?? '').trim();
      final savedProviderName = prefs.getString(_prefKeyProvider) ?? 'auto';
      _runtimeProvider = AiProviderMode.values.firstWhere(
        (p) => p.name == savedProviderName,
        orElse: () => AiProviderMode.auto,
      );
      _runtimeModel = (prefs.getString(_prefKeyModel) ?? '').trim();
    } catch (_) {
      // Aman diabaikan pada unit test murni tanpa binding SharedPreferences.
    }
  }

  /// Menyimpan konfigurasi API Key & provider pengguna ke penyimpanan lokal perangkat.
  Future<void> saveRuntimeConfig({
    required String apiKey,
    AiProviderMode provider = AiProviderMode.auto,
    String? model,
  }) async {
    final trimmedKey = apiKey.trim();
    final trimmedModel = (model ?? '').trim();
    _runtimeApiKey = trimmedKey;
    _runtimeProvider = provider;
    _runtimeModel = trimmedModel;
    _discoveredGeminiModel = null;
    _runtimeLoaded = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyApiKey, trimmedKey);
      await prefs.setString(_prefKeyProvider, provider.name);
      await prefs.setString(_prefKeyModel, trimmedModel);
    } catch (_) {}
  }

  /// Menghapus konfigurasi runtime pengguna (kembali ke mode default publik / dart-define).
  Future<void> clearRuntimeConfig() async {
    _runtimeApiKey = '';
    _runtimeProvider = AiProviderMode.auto;
    _runtimeModel = '';
    _discoveredGeminiModel = null;
    _runtimeLoaded = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyApiKey);
      await prefs.remove(_prefKeyProvider);
      await prefs.remove(_prefKeyModel);
    } catch (_) {}
  }

  /// Mengetahui apakah ada API Key runtime yang tersimpan oleh pengguna di perangkat.
  bool get hasRuntimeApiKey => _runtimeApiKey.isNotEmpty;

  /// Mengambil provider tersimpan di runtime UI.
  AiProviderMode get savedRuntimeProvider => _runtimeProvider;

  /// Mengambil nama model tersimpan di runtime UI.
  String get savedRuntimeModel => _runtimeModel;

  /// Kredensial aktif (prioritas: konstruktor -> runtime pengguna -> --dart-define).
  String get effectiveApiKey {
    if (apiKey != null) return apiKey!;
    if (_runtimeApiKey.isNotEmpty) return _runtimeApiKey;
    return AppConfig.llmApiKey;
  }

  /// Deteksi otomatis provider AI berdasarkan awalan API Key.
  static AiProviderMode detectProviderFromKey(String rawKey) {
    final key = rawKey.trim();
    if (key.startsWith('AIza')) return AiProviderMode.gemini;
    if (key.startsWith('gsk_')) return AiProviderMode.groq;
    if (key.startsWith('sk-or-')) return AiProviderMode.openRouter;
    if (key.startsWith('pk_') || key.startsWith('sk_')) {
      return AiProviderMode.pollinations;
    }
    if (key.startsWith('sk-')) return AiProviderMode.openAi;
    return AiProviderMode.gemini;
  }

  /// Provider aktif yang sedang dipakai.
  AiProviderMode get effectiveProvider {
    if (_explicitProvider != null && _explicitProvider != AiProviderMode.auto) {
      return _explicitProvider;
    }
    final activeKey = effectiveApiKey.trim();
    if (activeKey.isEmpty) return AiProviderMode.pollinations;
    if (apiKey == null && _runtimeProvider != AiProviderMode.auto) {
      return _runtimeProvider;
    }
    return detectProviderFromKey(activeKey);
  }

  /// Model aktif yang digunakan oleh provider terpilih.
  String get effectiveModel {
    if (model != null) {
      final candidate = model!.trim();
      final sanitized = candidate.replaceFirst(RegExp(r'^/?(models/)?'), '');
      if (sanitized.isNotEmpty) return candidate;
    }
    if (apiKey == null && _runtimeModel.isNotEmpty) {
      return _runtimeModel;
    }
    if (effectiveProvider == AiProviderMode.gemini) {
      if (_discoveredGeminiModel != null && _discoveredGeminiModel!.isNotEmpty) {
        return _discoveredGeminiModel!;
      }
      final fallback = AppConfig.geminiModel
          .trim()
          .replaceFirst(RegExp(r'^/?(models/)?'), '');
      return fallback.isNotEmpty ? fallback : 'gemini-2.5-flash';
    }
    return effectiveProvider.defaultModel;
  }

  /// Menentukan apakah user/build API Key eksternal telah dikonfigurasi.
  bool get isConfigured => effectiveApiKey.trim().isNotEmpty;

  /// Label status mesin AI untuk ditampilkan ke pengguna pada header.
  String get activeEngineStatusLabel {
    if (isConfigured) {
      switch (effectiveProvider) {
        case AiProviderMode.gemini:
        case AiProviderMode.auto:
          return 'Terhubung · Google Gemini';
        case AiProviderMode.groq:
          return 'Terhubung · Groq AI';
        case AiProviderMode.openRouter:
          return 'Terhubung · OpenRouter AI';
        case AiProviderMode.pollinations:
          return 'Terhubung · Pollinations AI';
        case AiProviderMode.openAi:
          return 'Terhubung · OpenAI';
      }
    }
    return 'Live AI Publik (Gratis) · Ketuk untuk atur key';
  }

  /// Sisa detik cooldown endpoint publik anonim bila sedang terkena jeda 45 detik.
  int? get publicCooldownRemainingSeconds {
    final until = _publicCooldownUntil;
    if (until == null) return null;
    final diff = until.difference(DateTime.now()).inSeconds;
    if (diff <= 0) {
      _publicCooldownUntil = null;
      return null;
    }
    return diff;
  }

  /// Prompt Dasar Pengetahuan Budaya & Pakem Adat
  static const String _defaultSystemPrompt = '''
Anda adalah "Abdi Pakar Busana JAVARA", asisten kurasi busana adat dan kebudayaan Jawa Tengah yang berwibawa, santun, berpengetahuan mendalam, dan memegang teguh paugeran (tatanan pakem) luhur Keraton Kasunanan Surakarta Hadiningrat, Pura Mangkunegaran, Yogyakarta, Banyumas, dan pesisir Pekalongan.

Prinsip & Pedoman Utama:
1. Rekomendasi Busana Sesuai Tatakrama Tradisi:
   - Pernikahan Ageng: Solo Basahan (Dodot Kampuh Semen Ageng) untuk kemegahan sakral kanarendran, atau Jawi Jangkep Langenharjan / Sikepan untuk akad dan resepsi formal.
   - Sowan Keraton & Upacara Ageng: Beskap Sikepan kancing emas, jarik wiru engkol Surakarta, dan stagen timang.
   - Busana Putri: Kebaya Kartini sutra/beludru dengan bordir halus, Kebaya Kutu Baru dengan stagen jumputan, selendang sutra, dan sanggul ukel tekuk atau bangun tulak.
2. Filosofi Wastra, Batik Larangan (Awisan Dalem) & Makna Simbolis:
   - Parang Barong & Parang Rusak: Simbol ombak samudera dan tekad ksatria pantang menyerah, dulunya eksklusif raja & putra mahkota.
   - Sido Mukti & Sido Asih: Melambangkan keluhuran hidup, derajat budi luhur, dan kelimpahan cinta kasih abadi.
   - Truntum: Diciptakan Kanjeng Ratu Kencana, melambangkan cinta yang bersemi kembali (tumaruntum), wajib untuk orang tua mempelai.
   - Kawung: Simbol kemurnian hati, kesederhanaan, dan empat penjuru mata angin keadilan (sedulur papat lima pancer).
3. Aksesoris & Kelengkapan Busana Pria (Ricikan):
   - Blangkon Mondholan Trepes khas Kasunanan Surakarta (mengendalikan rahasia batin) vs Mondholan Tonjolan khas Yogyakarta.
   - Keris Ladrang (upacara resmi/pahargyan) vs Gayaman (keseharian/santai), diselipkan di pinggang belakang dengan kemiringan pas.
4. Gaya Komunikasi:
   - Santun, ringkas, akurat, menggunakan bahasa Indonesia yang baik serta sesekali diselingi unggah-ungguh basa Jawa krama alus yang relevan.
   - Gunakan fakta pada bagian REFERENSI DATA JAVARA (jika disertakan) secara akurat dan jangan mengarang definisi teknis yang bertentangan.
''';

  /// Prompt sistem yang aktif
  String get effectiveSystemPrompt =>
      _customSystemPrompt ?? _defaultSystemPrompt;

  String _buildGroundedSystemPrompt(String query) {
    final base = effectiveSystemPrompt;
    final ragContext = AiCulturalKnowledgeBase.buildRagContext(query);
    if (ragContext.isEmpty) return base;
    return '$base\n\nREFERENSI DATA JAVARA (Gunakan fakta berikut sebagai acuan utama):\n$ragContext';
  }

  /// Membangun URL Endpoint Google Gemini API
  Uri buildEndpointUrl({String? overrideModel, String? overrideKey}) {
    final rawModel = (overrideModel ?? effectiveModel).trim();
    final sanitized = rawModel.replaceFirst(RegExp(r'^/?(models/)?'), '');
    final fallbackDefault = AppConfig.geminiModel
        .trim()
        .replaceFirst(RegExp(r'^/?(models/)?'), '');
    final cleanModel = sanitized.isNotEmpty
        ? sanitized
        : (fallbackDefault.isNotEmpty ? fallbackDefault : 'gemini-2.5-flash');
    final key = (overrideKey ?? effectiveApiKey).trim();
    return Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$cleanModel:generateContent',
      {'key': key},
    );
  }

  /// Menguji kredensial AI secara live dan menyimpannya bila berhasil.
  Future<AiConnectionTestResult> testAndSaveRuntimeConfig({
    required String apiKey,
    AiProviderMode provider = AiProviderMode.auto,
    String? model,
  }) async {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      return const AiConnectionTestResult(
        ok: false,
        message: 'Masukkan API Key terlebih dahulu.',
        provider: AiProviderMode.auto,
      );
    }

    final resolvedProvider = provider == AiProviderMode.auto
        ? detectProviderFromKey(trimmedKey)
        : provider;
    final requestedModel = (model ?? '').trim();
    final resolvedModel = requestedModel.isNotEmpty
        ? requestedModel
        : resolvedProvider.defaultModel;

    try {
      if (resolvedProvider == AiProviderMode.gemini) {
        var activeModel = resolvedModel;
        var url = buildEndpointUrl(
          overrideModel: activeModel,
          overrideKey: trimmedKey,
        );
        final payload = {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': 'Jawab singkat: OK'}
              ]
            }
          ],
          'generationConfig': {'maxOutputTokens': 16},
        };

        var res = await _postJson(
          url,
          const {'Content-Type': 'application/json'},
          payload,
        );

        if (res.statusCode == 404 && requestedModel.isEmpty) {
          final discovered = await _discoverActiveGeminiModel(trimmedKey);
          if (discovered != null) {
            activeModel = discovered;
            url = buildEndpointUrl(
              overrideModel: activeModel,
              overrideKey: trimmedKey,
            );
            res = await _postJson(
              url,
              const {'Content-Type': 'application/json'},
              payload,
            );
          }
        }

        if (res.statusCode == 200) {
          await saveRuntimeConfig(
            apiKey: trimmedKey,
            provider: resolvedProvider,
            model: activeModel,
          );
          _discoveredGeminiModel = activeModel;
          return AiConnectionTestResult(
            ok: true,
            message: 'Terhubung ke Google Gemini ($activeModel)!',
            provider: resolvedProvider,
            model: activeModel,
          );
        }

        return AiConnectionTestResult(
          ok: false,
          message: _formatHttpErrorMessage(res.statusCode, res.body),
          provider: resolvedProvider,
          model: activeModel,
        );
      }

      // OpenAI-compatible provider test (Groq, OpenRouter, Pollinations, OpenAI)
      final gatewayUrl = _openAiEndpointFor(resolvedProvider, hasKey: true);
      final res = await _postJson(
        gatewayUrl,
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $trimmedKey',
          if (resolvedProvider == AiProviderMode.openRouter) ...{
            'HTTP-Referer': 'https://javara.app',
            'X-Title': 'JAVARA Cultural Fashion',
          },
        },
        {
          'model': resolvedModel,
          'messages': [
            {'role': 'user', 'content': 'Jawab singkat: OK'}
          ],
          'max_tokens': 16,
        },
      );

      if (res.statusCode == 200) {
        await saveRuntimeConfig(
          apiKey: trimmedKey,
          provider: resolvedProvider,
          model: requestedModel,
        );
        return AiConnectionTestResult(
          ok: true,
          message:
              'Terhubung ke ${resolvedProvider.label} ($resolvedModel)!',
          provider: resolvedProvider,
          model: resolvedModel,
        );
      }

      return AiConnectionTestResult(
        ok: false,
        message: _formatHttpErrorMessage(res.statusCode, res.body),
        provider: resolvedProvider,
        model: resolvedModel,
      );
    } on TimeoutException {
      return AiConnectionTestResult(
        ok: false,
        message: 'Koneksi timeout. Periksa jaringan internet Anda.',
        provider: resolvedProvider,
      );
    } catch (e) {
      return AiConnectionTestResult(
        ok: false,
        message: 'Gagal menghubungi server AI: $e',
        provider: resolvedProvider,
      );
    }
  }

  String _formatHttpErrorMessage(int statusCode, String body) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return 'API Key ditolak atau tidak valid (HTTP $statusCode).';
    }
    if (statusCode == 429) {
      return 'Kuota atau rate limit API tercapai (HTTP 429). Coba beberapa saat lagi.';
    }
    if (statusCode == 402) {
      return 'Kredit/saldo akun AI habis atau butuh autentikasi (HTTP 402).';
    }
    return 'Server AI merespons HTTP $statusCode.';
  }

  /// Memproses Pesan Pengguna dan Mengembalikan Jawaban Terstruktur
  Future<AssistantChatMessage> sendMessage(
    String query, {
    List<AssistantChatMessage>? history,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Nyuwun sewu, katuran nyerat pitakon panjenengan babagan busana adat Jawa Tengah.',
        timestamp: DateTime.now(),
        sourceReference: 'Abdi Pakar Busana JAVARA',
      );
    }

    if (apiKey == null) {
      await initialize();
    }

    final activeHistory = history ?? _sessionHistory;
    final groundedPrompt = _buildGroundedSystemPrompt(trimmedQuery);

    // Jalur A: Kredensial eksplisit pengguna / build flag terkonfigurasi
    if (isConfigured) {
      try {
        AssistantChatMessage? reply;
        if (effectiveProvider == AiProviderMode.gemini) {
          reply = await _callGeminiApi(
            query: trimmedQuery,
            history: activeHistory,
            systemPrompt: groundedPrompt,
          );
        } else {
          reply = await _callOpenAiCompatibleApi(
            provider: effectiveProvider,
            apiKey: effectiveApiKey.trim(),
            modelName: effectiveModel,
            query: trimmedQuery,
            history: activeHistory,
            systemPrompt: groundedPrompt,
          );
        }
        if (reply != null) {
          _recordTurn(trimmedQuery, reply);
          return reply;
        }
      } catch (e) {
        debugPrint('[AiCulturalAssistantService] Configured AI call error: $e');
      }

      // Fallback kurasi lokal bila provider privat gagal / timeout / offline
      await Future.delayed(const Duration(milliseconds: 200));
      final fallback =
          AiCulturalKnowledgeBase.generateLocalResponse(trimmedQuery);
      _recordTurn(trimmedQuery, fallback);
      return fallback;
    }

    // Jalur B: Mode Publik Tanpa API Key (Pollinations Keyless + Wikipedia ID + Kurasi RAG)
    if (enablePublicAiFallback && publicCooldownRemainingSeconds == null) {
      try {
        final publicReply = await _callOpenAiCompatibleApi(
          provider: AiProviderMode.pollinations,
          apiKey: '',
          modelName: 'openai-fast',
          query: trimmedQuery,
          history: activeHistory,
          systemPrompt: groundedPrompt,
        );
        if (publicReply != null) {
          _recordTurn(trimmedQuery, publicReply);
          return publicReply;
        }
      } catch (e) {
        debugPrint('[AiCulturalAssistantService] Public AI fallback error: $e');
      }
    }

    // Jika pertanyaan bersifat umum/ensiklopedis dan AI publik sedang jeda/gagal,
    // ambil rangkuman live dari Wikipedia Indonesia agar jawaban tetap relevan & faktual.
    String? wikiTitle;
    String? wikiSummary;
    if (enablePublicAiFallback &&
        !AiCulturalKnowledgeBase.hasStrongCatalogMatch(trimmedQuery)) {
      final wiki = await _fetchWikipediaSummary(trimmedQuery);
      wikiTitle = wiki?.title;
      wikiSummary = wiki?.summary;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final fallbackReply = AiCulturalKnowledgeBase.generateLocalResponse(
      trimmedQuery,
      wikipediaTitle: wikiTitle,
      wikipediaSummary: wikiSummary,
      publicCooldownSeconds: publicCooldownRemainingSeconds,
    );
    _recordTurn(trimmedQuery, fallbackReply);
    return fallbackReply;
  }

  /// Mencatat turn percakapan ke dalam riwayat sesi
  void _recordTurn(String userText, AssistantChatMessage assistantMsg) {
    _sessionHistory.add(
      AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.user,
        text: userText,
        timestamp: DateTime.now(),
      ),
    );
    _sessionHistory.add(assistantMsg);
  }

  Future<http.Response> _postJson(
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) {
    final encoded = jsonEncode(body);
    final client = httpClient;
    final future = client != null
        ? client.post(url, headers: headers, body: encoded)
        : http.post(url, headers: headers, body: encoded);
    return future.timeout(requestTimeout);
  }

  Future<http.Response> _getRequest(
    Uri url, {
    Map<String, String>? headers,
  }) {
    final client = httpClient;
    final future = client != null
        ? client.get(url, headers: headers)
        : http.get(url, headers: headers);
    return future.timeout(requestTimeout);
  }

  /// Membangun format multi-turn contents sesuai spesifikasi Google Gemini API
  List<Map<String, dynamic>> buildGeminiContents({
    required String query,
    List<AssistantChatMessage>? history,
  }) {
    final List<Map<String, dynamic>> contents = [];

    if (history != null && history.isNotEmpty) {
      final firstUserIndex =
          history.indexWhere((m) => m.role == AssistantRole.user);

      if (firstUserIndex != -1) {
        final relevantHistory = history.sublist(firstUserIndex);

        var trimmedHistory = relevantHistory.length > 20
            ? relevantHistory.sublist(relevantHistory.length - 20)
            : relevantHistory;

        final trimmedFirstUserIndex =
            trimmedHistory.indexWhere((m) => m.role == AssistantRole.user);
        if (trimmedFirstUserIndex != -1) {
          trimmedHistory = trimmedHistory.sublist(trimmedFirstUserIndex);
        }

        for (final msg in trimmedHistory) {
          if (msg.role == AssistantRole.system) continue;

          final role = msg.role == AssistantRole.user ? 'user' : 'model';
          final text = msg.text.trim();
          if (text.isEmpty) continue;

          if (contents.isNotEmpty && contents.last['role'] == role) {
            final parts = contents.last['parts'] as List;
            if (parts.isNotEmpty && parts.first is Map) {
              final prevText = parts.first['text'] as String? ?? '';
              parts.first['text'] = '$prevText\n\n$text';
            }
          } else {
            contents.add({
              'role': role,
              'parts': [
                {'text': text}
              ],
            });
          }
        }
      }
    }

    while (contents.isNotEmpty && contents.first['role'] != 'user') {
      contents.removeAt(0);
    }

    final trimmedQuery = query.trim();
    final effectiveQueryText =
        trimmedQuery.isNotEmpty ? trimmedQuery : 'Paugeran Busana Adat';

    if (contents.isEmpty) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': effectiveQueryText}
        ],
      });
      return contents;
    }

    final lastContent = contents.last;
    final lastParts = lastContent['parts'] as List;
    final lastText = lastParts.isNotEmpty && lastParts.first is Map
        ? (lastParts.first['text'] as String? ?? '')
        : '';

    if (lastContent['role'] == 'user' &&
        (lastText == trimmedQuery || lastText == effectiveQueryText)) {
      return contents;
    }

    if (lastContent['role'] == 'user') {
      if (trimmedQuery.isNotEmpty) {
        lastParts.first['text'] = '$lastText\n\n$trimmedQuery';
      }
    } else {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': effectiveQueryText}
        ],
      });
    }

    return contents;
  }

  /// Panggilan HTTP langsung ke Google Gemini API dengan auto-discovery model bila HTTP 404.
  Future<AssistantChatMessage?> _callGeminiApi({
    required String query,
    required List<AssistantChatMessage>? history,
    required String systemPrompt,
  }) async {
    var url = buildEndpointUrl();
    final formattedContents =
        buildGeminiContents(query: query, history: history);

    final payloadWithSystemInstruction = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': formattedContents,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      },
    };

    const headers = {'Content-Type': 'application/json'};

    http.Response response;
    try {
      response = await _postJson(url, headers, payloadWithSystemInstruction);
    } catch (e) {
      debugPrint('[AiCulturalAssistantService] Network or Timeout error: $e');
      return null;
    }

    // Jika model default/lama mengembalikan 404 Not Found, cari model aktif dari API key ini.
    if (response.statusCode == 404) {
      final activeModel = await _discoverActiveGeminiModel(effectiveApiKey);
      if (activeModel != null) {
        _discoveredGeminiModel = activeModel;
        url = buildEndpointUrl(overrideModel: activeModel);
        try {
          response =
              await _postJson(url, headers, payloadWithSystemInstruction);
        } catch (e) {
          debugPrint('[AiCulturalAssistantService] Discovery retry error: $e');
          return null;
        }
      }
    }

    // Bila endpoint lawas menolak field system_instruction, fallback retry sisip ke turn pertama.
    final lowerErrorBody = response.body.toLowerCase();
    if (response.statusCode == 400 &&
        (lowerErrorBody.contains('system_instruction') ||
            lowerErrorBody.contains('systeminstruction') ||
            lowerErrorBody.contains('developer instruction'))) {
      debugPrint(
        '[AiCulturalAssistantService] system_instruction tidak didukung, mengirim ulang dengan prompt tersemat.',
      );
      final fallbackContents = _prependSystemPromptToContents(
        formattedContents,
        systemPrompt,
      );
      final fallbackPayload = {
        'contents': fallbackContents,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };

      try {
        response = await _postJson(url, headers, fallbackPayload);
      } catch (e) {
        debugPrint('[AiCulturalAssistantService] Retry network error: $e');
        return null;
      }
    }

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final replyText = _extractTextFromGeminiResponse(data);
        if (replyText != null && replyText.isNotEmpty) {
          final action =
              AiCulturalKnowledgeBase.resolveContextualAction(query, replyText);
          return AssistantChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: AssistantRole.assistant,
            text: replyText,
            timestamp: DateTime.now(),
            sourceReference: 'Didukung oleh Google Gemini Pro · Pakem JAVARA',
            action: action,
          );
        }
      } catch (e) {
        debugPrint(
          '[AiCulturalAssistantService] Gagal membaca struktur JSON respons: $e',
        );
      }
    } else {
      debugPrint(
        '[AiCulturalAssistantService] Gemini API merespons HTTP ${response.statusCode}: ${response.body}',
      );
    }

    return null;
  }

  /// Mengambil daftar model aktif milik API Key Gemini pengguna apabila model default 404.
  Future<String?> _discoverActiveGeminiModel(String key) async {
    try {
      final listUri = Uri.https(
        'generativelanguage.googleapis.com',
        '/v1beta/models',
        {'key': key.trim()},
      );
      final res = await _getRequest(listUri);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final models = data['models'] as List?;
      if (models == null || models.isEmpty) return null;

      final candidates = <String>[];
      for (final m in models) {
        if (m is! Map) continue;
        final name = (m['name'] as String? ?? '')
            .replaceFirst(RegExp(r'^models/'), '');
        final methods =
            (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? [];
        if (name.startsWith('gemini-') &&
            methods.contains('generateContent') &&
            !name.contains('embedding') &&
            !name.contains('tts') &&
            !name.contains('image') &&
            !name.contains('vision')) {
          candidates.add(name);
        }
      }

      if (candidates.isEmpty) return null;

      // Prioritaskan model Flash/Pro terbaru
      for (final prefix in ['gemini-3', 'gemini-2.5-flash', 'gemini-2.5']) {
        final match = candidates.where((c) => c.startsWith(prefix)).toList();
        if (match.isNotEmpty) return match.first;
      }
      return candidates.first;
    } catch (_) {
      return null;
    }
  }

  /// Membangun daftar messages standar OpenAI-compatible (system -> history -> user).
  List<Map<String, String>> buildOpenAiMessages({
    required String query,
    required String systemPrompt,
    List<AssistantChatMessage>? history,
  }) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (history != null && history.isNotEmpty) {
      final firstUserIndex =
          history.indexWhere((m) => m.role == AssistantRole.user);
      if (firstUserIndex != -1) {
        var relevant = history.sublist(firstUserIndex);
        if (relevant.length > 16) {
          relevant = relevant.sublist(relevant.length - 16);
        }
        for (final msg in relevant) {
          if (msg.role == AssistantRole.system) continue;
          final text = msg.text.trim();
          if (text.isEmpty) continue;
          messages.add({
            'role': msg.role == AssistantRole.user ? 'user' : 'assistant',
            'content': text,
          });
        }
      }
    }

    final trimmedQuery = query.trim();
    if (messages.length == 1 ||
        messages.last['role'] != 'user' ||
        messages.last['content'] != trimmedQuery) {
      messages.add({'role': 'user', 'content': trimmedQuery});
    }

    return messages;
  }

  Uri _openAiEndpointFor(AiProviderMode provider, {required bool hasKey}) {
    switch (provider) {
      case AiProviderMode.groq:
        return Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      case AiProviderMode.openRouter:
        return Uri.parse('https://openrouter.ai/api/v1/chat/completions');
      case AiProviderMode.openAi:
        return Uri.parse('https://api.openai.com/v1/chat/completions');
      case AiProviderMode.pollinations:
        return hasKey
            ? Uri.parse('https://gen.pollinations.ai/v1/chat/completions')
            : Uri.parse('https://text.pollinations.ai/openai');
      case AiProviderMode.auto:
      case AiProviderMode.gemini:
        return Uri.parse('https://api.openai.com/v1/chat/completions');
    }
  }

  /// Gateway HTTP OpenAI-compatible (untuk Groq, OpenRouter, OpenAI, dan Pollinations).
  Future<AssistantChatMessage?> _callOpenAiCompatibleApi({
    required AiProviderMode provider,
    required String apiKey,
    required String modelName,
    required String query,
    required List<AssistantChatMessage>? history,
    required String systemPrompt,
  }) async {
    final hasKey = apiKey.isNotEmpty;
    final endpoint = _openAiEndpointFor(provider, hasKey: hasKey);
    final messages = buildOpenAiMessages(
      query: query,
      systemPrompt: systemPrompt,
      history: history,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (hasKey) 'Authorization': 'Bearer $apiKey',
      if (provider == AiProviderMode.openRouter) ...{
        'HTTP-Referer': 'https://javara.app',
        'X-Title': 'JAVARA Cultural Fashion',
      },
    };

    final payload = {
      'model': modelName,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 900,
    };

    http.Response response;
    try {
      response = await _postJson(endpoint, headers, payload);
    } catch (e) {
      debugPrint(
        '[AiCulturalAssistantService] OpenAI-compatible network error: $e',
      );
      return null;
    }

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final replyText = _extractTextFromOpenAiResponse(data);
        if (replyText != null && replyText.isNotEmpty) {
          final action =
              AiCulturalKnowledgeBase.resolveContextualAction(query, replyText);
          final source = hasKey
              ? 'Didukung oleh ${provider.label} · Pakem JAVARA'
              : 'Live AI · Pollinations (Gratis) · Pakem JAVARA';
          return AssistantChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: AssistantRole.assistant,
            text: replyText,
            timestamp: DateTime.now(),
            sourceReference: source,
            action: action,
          );
        }
      } catch (e) {
        debugPrint(
          '[AiCulturalAssistantService] OpenAI-compatible JSON parse error: $e',
        );
      }
    } else if (response.statusCode == 402 && !hasKey) {
      final retryMatch = RegExp(r'(\d+)s').firstMatch(response.body);
      final waitSecs = int.tryParse(retryMatch?.group(1) ?? '') ?? 45;
      _publicCooldownUntil =
          DateTime.now().add(Duration(seconds: waitSecs.clamp(5, 120)));
      debugPrint(
        '[AiCulturalAssistantService] Pollinations public cooldown ($waitSecs s).',
      );
    } else {
      debugPrint(
        '[AiCulturalAssistantService] ${provider.label} merespons HTTP ${response.statusCode}: ${response.body}',
      );
    }

    return null;
  }

  /// Pencarian ringan live ke Wikipedia Indonesia bila pertanyaan tidak cocok kuat di katalog lokal.
  Future<({String title, String summary})?> _fetchWikipediaSummary(
      String query) async {
    try {
      final cleanQuery = query
          .replaceAll(RegExp(r'\b(apa itu|siapa|ceritakan|tentang|jelaskan|mengapa)\b', caseSensitive: false), '')
          .trim();
      final searchKeyword = cleanQuery.isNotEmpty ? cleanQuery : query;

      final searchUri = Uri.https('id.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'list': 'search',
        'srsearch': searchKeyword,
        'format': 'json',
        'utf8': '1',
        'srlimit': '1',
      });

      final searchRes = await _getRequest(searchUri, headers: _wikiHeaders);
      if (searchRes.statusCode != 200) return null;

      final searchJson = jsonDecode(searchRes.body) as Map<String, dynamic>;
      final results = (searchJson['query'] as Map?)?['search'] as List?;
      if (results == null || results.isEmpty) return null;

      final topTitle = (results.first as Map)['title'] as String?;
      if (topTitle == null || topTitle.trim().isEmpty) return null;

      final encodedTitle = Uri.encodeComponent(topTitle.replaceAll(' ', '_'));
      final summaryUri = Uri.parse(
        'https://id.wikipedia.org/api/rest_v1/page/summary/$encodedTitle',
      );
      final summaryRes = await _getRequest(summaryUri, headers: _wikiHeaders);
      if (summaryRes.statusCode != 200) return null;

      final summaryJson = jsonDecode(summaryRes.body) as Map<String, dynamic>;
      final extract = (summaryJson['extract'] as String? ?? '').trim();
      if (extract.isEmpty) return null;

      return (title: topTitle, summary: extract);
    } catch (_) {
      return null;
    }
  }

  /// Menyisipkan prompt sistem ke bagian atas contents untuk kompatibilitas
  List<Map<String, dynamic>> _prependSystemPromptToContents(
    List<Map<String, dynamic>> contents,
    String systemPrompt,
  ) {
    if (contents.isEmpty) {
      return [
        {
          'role': 'user',
          'parts': [
            {'text': '$systemPrompt\n\n[Mulai Sesi]'}
          ]
        }
      ];
    }

    final copy = contents.map((c) {
      final parts = (c['parts'] as List)
          .map((p) => Map<String, dynamic>.from(p as Map))
          .toList();
      return {
        'role': c['role'],
        'parts': parts,
      };
    }).toList();

    final firstPart = copy.first['parts'] as List;
    final originalText = firstPart.first['text'] as String? ?? '';
    firstPart.first['text'] = '$systemPrompt\n\n$originalText';

    return copy;
  }

  /// Ekstraksi teks aman dari payload respons Gemini API
  String? _extractTextFromGeminiResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      if (firstCandidate == null) return null;

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;

      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is Map &&
            part['thought'] != true &&
            part['text'] is String) {
          buffer.write(part['text']);
        }
      }

      final text = buffer.toString().trim();
      return text.isNotEmpty ? text : null;
    } catch (e) {
      debugPrint(
        '[AiCulturalAssistantService] Gagal ekstraksi teks Gemini: $e',
      );
      return null;
    }
  }

  /// Ekstraksi teks aman dari payload respons OpenAI-compatible
  String? _extractTextFromOpenAiResponse(Map<String, dynamic> data) {
    try {
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      final firstChoice = choices.first as Map<String, dynamic>?;
      if (firstChoice == null) return null;

      final message = firstChoice['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      final trimmed = content?.trim();
      return (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
    } catch (_) {
      return null;
    }
  }
}
