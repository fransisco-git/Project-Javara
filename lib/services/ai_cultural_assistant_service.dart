import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../features/fashion/data/javanese_clothing_data.dart';
import '../features/fashion/models/javanese_clothing_models.dart';

/// Jenis Pesan Asisten Budaya
enum AssistantRole { user, assistant, system }

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
/// Menyediakan penalaran busana adat berbasis pengetahuan budaya terverifikasi
/// Keraton Kasunanan Surakarta & Jawa Tengah, terhubung langsung ke Google Gemini Pro API
/// dengan dukungan percakapan multi-turn, grounding paugeran adat, dan fallback offline aman.
class AiCulturalAssistantService {
  AiCulturalAssistantService({
    this.httpClient,
    this.apiKey,
    this.model,
    String? systemPrompt,
    this.requestTimeout = const Duration(seconds: 12),
  }) : _customSystemPrompt = systemPrompt;

  /// Singleton instance default untuk aplikasi
  static AiCulturalAssistantService instance = AiCulturalAssistantService();

  final http.Client? httpClient;
  final String? apiKey;
  final String? model;
  final String? _customSystemPrompt;
  final Duration requestTimeout;

  final List<AssistantChatMessage> _sessionHistory = [];

  /// Riwayat percakapan sesi aktif
  List<AssistantChatMessage> get sessionHistory =>
      List.unmodifiable(_sessionHistory);

  /// Menghapus riwayat percakapan sesi
  void clearSession() {
    _sessionHistory.clear();
  }

  /// Kredensial aktif Gemini API
  String get effectiveApiKey => apiKey ?? AppConfig.llmApiKey;

  /// Model Gemini yang digunakan
  String get effectiveModel {
    final candidate = (model ?? AppConfig.geminiModel).trim();
    final sanitized = candidate.replaceFirst(RegExp(r'^/?(models/)?'), '');
    if (sanitized.isEmpty) {
      final fallback = AppConfig.geminiModel
          .trim()
          .replaceFirst(RegExp(r'^/?(models/)?'), '');
      return fallback.isNotEmpty ? fallback : 'gemini-1.5-pro';
    }
    return candidate;
  }

  /// Menentukan apakah Gemini Pro API telah terkonfigurasi
  bool get isConfigured => effectiveApiKey.trim().isNotEmpty;

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
   - Santun, elegan, mendalam, menggunakan bahasa Indonesia baku yang sesekali diselingi kosakata atau unggah-ungguh basa Jawa krama alus yang relevan.
   - Rujuk sumber resmi kepustakaan Jawa (Serat Centhini, Serat Tatacara Karaton Surakarta, Pawiyatan Kabudayan).
''';

  /// Prompt sistem yang aktif
  String get effectiveSystemPrompt =>
      _customSystemPrompt ?? _defaultSystemPrompt;

  /// Membangun URL Endpoint Google Gemini API
  Uri buildEndpointUrl() {
    final rawModel = effectiveModel.trim();
    final sanitized = rawModel.replaceFirst(RegExp(r'^/?(models/)?'), '');
    final cleanModel = sanitized.isNotEmpty ? sanitized : 'gemini-1.5-pro';
    final key = effectiveApiKey.trim();
    return Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$cleanModel:generateContent',
      {'key': key},
    );
  }

  /// Memproses Pesan Pengguna dan Mengembalikan Jawaban Terstruktur
  ///
  /// Mendukung multi-turn conversation dengan menyertakan [history] sebelumnya.
  /// Jika Gemini API terkonfigurasi, mengirim permintaan langsung ke Gemini Pro.
  /// Jika tidak atau terjadi kendala jaringan/timeout/rate limit, beralih ke kurasi lokal terverifikasi.
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

    final activeHistory = history ?? _sessionHistory;

    // 1. Panggilan Live ke Google Gemini Pro API jika API Key tersedia
    if (isConfigured) {
      try {
        final geminiReply = await _callGeminiApi(
          query: trimmedQuery,
          history: activeHistory,
        );
        if (geminiReply != null) {
          _recordTurn(trimmedQuery, geminiReply);
          return geminiReply;
        }
      } catch (e) {
        debugPrint('[AiCulturalAssistantService] Gemini API call fallback: $e');
      }
    }

    // 2. Fallback offline aman ke kurasi adat terverifikasi
    await Future.delayed(const Duration(milliseconds: 300));
    final fallbackReply = _generateCuratedFallback(trimmedQuery);
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

  /// Membangun format multi-turn contents sesuai spesifikasi Google Gemini API
  List<Map<String, dynamic>> buildGeminiContents({
    required String query,
    List<AssistantChatMessage>? history,
  }) {
    final List<Map<String, dynamic>> contents = [];

    if (history != null && history.isNotEmpty) {
      // Abaikan pesan greeting pembuka sebelum pesan pengguna pertama
      final firstUserIndex =
          history.indexWhere((m) => m.role == AssistantRole.user);

      if (firstUserIndex != -1) {
        final relevantHistory = history.sublist(firstUserIndex);

        // Batasi maksimal 20 turn terakhir agar tetap efisien dalam batas kuota token
        var trimmedHistory = relevantHistory.length > 20
            ? relevantHistory.sublist(relevantHistory.length - 20)
            : relevantHistory;

        // Pastikan turn pertama dari trimmed history selalu dimulai oleh role user
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

          // Gabungkan pesan berurutan dengan role yang sama untuk mematuhi aturan alternasi Gemini
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

    // Pastikan bahwa isi contents tidak pernah diawali oleh role 'model'
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

    // Periksa apakah pesan query saat ini sudah menjadi elemen pengguna terakhir di history
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

  /// Panggilan HTTP langsung ke Google Gemini Pro API
  Future<AssistantChatMessage?> _callGeminiApi({
    required String query,
    required List<AssistantChatMessage>? history,
  }) async {
    final url = buildEndpointUrl();
    final formattedContents =
        buildGeminiContents(query: query, history: history);

    final payloadWithSystemInstruction = {
      'system_instruction': {
        'parts': [
          {'text': effectiveSystemPrompt}
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

    final headers = {'Content-Type': 'application/json'};

    final client = httpClient;
    http.Response response;
    try {
      final postFuture = client != null
          ? client.post(
              url,
              headers: headers,
              body: jsonEncode(payloadWithSystemInstruction),
            )
          : http.post(
              url,
              headers: headers,
              body: jsonEncode(payloadWithSystemInstruction),
            );

      response = await postFuture.timeout(requestTimeout);
    } catch (e) {
      debugPrint('[AiCulturalAssistantService] Network or Timeout error: $e');
      return null;
    }

    // Bila endpoint lawas menolak field system_instruction, lakukan fallback retry dengan menyisipkan ke user turn pertama
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
        effectiveSystemPrompt,
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
        final retryFuture = client != null
            ? client.post(
                url,
                headers: headers,
                body: jsonEncode(fallbackPayload),
              )
            : http.post(
                url,
                headers: headers,
                body: jsonEncode(fallbackPayload),
              );

        response = await retryFuture.timeout(requestTimeout);
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
          final action = _resolveContextualAction(query, replyText);
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
            '[AiCulturalAssistantService] Gagal membaca struktur JSON respons: $e');
      }
    } else {
      debugPrint(
        '[AiCulturalAssistantService] Gemini API merespons HTTP ${response.statusCode}: ${response.body}',
      );
    }

    return null;
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
          '[AiCulturalAssistantService] Gagal ekstraksi teks Gemini: $e');
      return null;
    }
  }

  /// Menghubungkan respons dengan aksi kurasi katalog / studio 3D kontekstual
  AssistantAction? _resolveContextualAction(
      String query, String responseText) {
    final combined = '${query.toLowerCase()} ${responseText.toLowerCase()}';

    // 1. Pernikahan / Solo Basahan
    if (combined.contains('basahan') ||
        combined.contains('dodot ageng') ||
        (combined.contains('pengantin') && combined.contains('solo'))) {
      final outfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.id.contains('basahan'),
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );
      return AssistantAction(
        type: 'outfit_recommendation',
        title: outfit.title,
        description: '${outfit.region.title} · ${outfit.socialContext}',
        targetOutfit: outfit,
      );
    }

    // 2. Setelan Resmi / Langenharjan / Sikepan / Jawi Jangkep
    if (combined.contains('langenharjan') ||
        combined.contains('jawi jangkep') ||
        combined.contains('sikepan') ||
        combined.contains('beskap')) {
      final outfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.id.contains('jangkep') || o.id.contains('langenharjan'),
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );
      return AssistantAction(
        type: 'outfit_recommendation',
        title: outfit.title,
        description: '${outfit.region.title} · ${outfit.socialContext}',
        targetOutfit: outfit,
      );
    }

    // 3. Motif Batik / Wastra
    if (combined.contains('parang') ||
        combined.contains('kawung') ||
        combined.contains('truntum') ||
        combined.contains('sido mukti') ||
        combined.contains('sido asih') ||
        combined.contains('motif batik') ||
        combined.contains('jarik')) {
      final garment = JavaneseClothingData.lowerBodyItems.firstWhere(
        (g) =>
            g.name.toLowerCase().contains('parang') ||
            g.name.toLowerCase().contains('batik'),
        orElse: () => JavaneseClothingData.lowerBodyItems.first,
      );
      return AssistantAction(
        type: 'batik_motif',
        title: garment.name,
        description: '${garment.region.title} · ${garment.javaneseScript}',
        targetGarment: garment,
      );
    }

    // 4. Penutup Kepala / Blangkon
    if (combined.contains('blangkon') ||
        combined.contains('mondholan') ||
        combined.contains('iket')) {
      final blangkon = JavaneseClothingData.headwearItems.first;
      return AssistantAction(
        type: 'garment_detail',
        title: blangkon.name,
        description: blangkon.javaneseScript,
        targetGarment: blangkon,
      );
    }

    // 5. Keris / Pusaka Adat
    if (combined.contains('keris') ||
        combined.contains('ladrang') ||
        combined.contains('gayaman')) {
      final keris = JavaneseClothingData.clothingItems.firstWhere(
        (i) => i.category == ClothingCategory.accessories,
        orElse: () => JavaneseClothingData.clothingItems.first,
      );
      return AssistantAction(
        type: 'garment_detail',
        title: keris.name,
        description: keris.javaneseScript,
        targetGarment: keris,
      );
    }

    // 6. Busana Putri / Kebaya
    if (combined.contains('kebaya') ||
        combined.contains('kuthubaru') ||
        combined.contains('kutu baru') ||
        combined.contains('putri') ||
        combined.contains('wanita')) {
      final kebaya = JavaneseClothingData.upperBodyItems.firstWhere(
        (i) => i.gender == GenderTarget.wanita,
        orElse: () => JavaneseClothingData.upperBodyItems.first,
      );
      return AssistantAction(
        type: 'garment_detail',
        title: kebaya.name,
        description: kebaya.javaneseScript,
        targetGarment: kebaya,
      );
    }

    return null;
  }

  /// Menghasilkan kurasi budaya lokal terverifikasi saat offline atau fallback
  AssistantChatMessage _generateCuratedFallback(String query) {
    final lower = query.toLowerCase();

    // Kasus A: Rekomendasi Busana Pernikahan / Upacara Ageng
    if (lower.contains('nikah') ||
        lower.contains('pengantin') ||
        lower.contains('wedding') ||
        lower.contains('pernikahan') ||
        lower.contains('manten') ||
        lower.contains('ijab')) {
      final outfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.id.contains('basahan') || o.id.contains('jangkep'),
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );

      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Untuk upacara pernikahan ageng adat Jawa Tengah (Surakarta), busana yang paling sakral dan penuh wibawa adalah **Solo Basahan (Dodot Ageng)** untuk kemegahan kanarendran, atau **Jawi Jangkep Langenharjan** untuk akad dan resepsi formal.\n\nBusana ini melambangkan penyatuan dua insan dalam restu Hyang Widhi dengan kain dodot kampuh sekar semen yang sarat doa kesuburan lahir batin.',
        timestamp: DateTime.now(),
        sourceReference:
            'Rujukan: Serat Tatacara Karaton Surakarta & Pawiyatan Kabudayan',
        action: AssistantAction(
          type: 'outfit_recommendation',
          title: outfit.title,
          description: '${outfit.region.title} · ${outfit.socialContext}',
          targetOutfit: outfit,
        ),
      );
    }

    // Kasus B: Filosofi Batik & Makna Motif
    if (lower.contains('batik') ||
        lower.contains('parang') ||
        lower.contains('motif') ||
        lower.contains('jarik') ||
        lower.contains('truntum') ||
        lower.contains('kawung')) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Motif batik pada busana Jawa memiliki tingkatan pakem yang sangat adiluhung:\n\n• **Parang Barong:** Diciptakan oleh Sultan Agung Hanyakrakusuma, melambangkan ombak samudera dan tekad ksatria pantang menyerah. Dahulu merupakan batik larangan (*awisan dalem*) yang hanya dikenakan raja dan putra mahkota.\n• **Sido Asih & Sido Mukti:** Melambangkan doa agar pemakainya senantiasa dilimpahi cinta kasih (*asih*) dan keluhuran derajat budi pekerti.\n• **Truntum:** Bermakna cinta yang bersemi kembali (*tumaruntum*), lazim dikenakan oleh orang tua mempelai.',
        timestamp: DateTime.now(),
        sourceReference:
            'Rujukan: Ensiklopedia Batik Adiluhung Keraton Kasunanan',
        action: AssistantAction(
          type: 'batik_motif',
          title: 'Batik Parang Barong Sogan',
          description:
              'Pola diagonal miring ombak karang laut selatan · Surakarta',
          targetGarment: JavaneseClothingData.lowerBodyItems.first,
        ),
      );
    }

    // Kasus C: Headwear / Blangkon
    if (lower.contains('blangkon') ||
        lower.contains('iket') ||
        lower.contains('kepala') ||
        lower.contains('mondholan')) {
      final blangkon = JavaneseClothingData.headwearItems.first;
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Ciri khas penutup kepala pria Surakarta adalah **Blangkon Mondholan Trepes**. Bagian belakang berbentuk pipih/ceper, melambangkan watak kesatria Jawa yang mampu mengubur dan mengendalikan rahasia batin serta emosi secara santun dan wibawa.',
        timestamp: DateTime.now(),
        sourceReference:
            'Rujukan: Makna Simbolik Busana Adat Pria Jawi Jangkep',
        action: AssistantAction(
          type: 'garment_detail',
          title: blangkon.name,
          description: blangkon.javaneseScript,
          targetGarment: blangkon,
        ),
      );
    }

    // Kasus D: Keris & Pusaka
    if (lower.contains('keris') ||
        lower.contains('ladrang') ||
        lower.contains('gayaman') ||
        lower.contains('pusaka')) {
      final keris = JavaneseClothingData.clothingItems.firstWhere(
        (i) => i.category == ClothingCategory.accessories,
        orElse: () => JavaneseClothingData.clothingItems.first,
      );
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Dalam kelengkapan Jawi Jangkep, **Keris Gaya Ladrang Surakarta** adalah warangka utama untuk pahargyan resmi dan sowan keraton. Bentuk warangka menyerupai kapal yang berlayar gagah di samudra, melambangkan kesiapan ksatria membina rumah tangga dan melindungi kehormatan.',
        timestamp: DateTime.now(),
        sourceReference: 'Rujukan: Kawruh Kagunan Dhuwung Surakarta',
        action: AssistantAction(
          type: 'garment_detail',
          title: keris.name,
          description: keris.javaneseScript,
          targetGarment: keris,
        ),
      );
    }

    // Kasus E: Busana Putri / Kebaya
    if (lower.contains('kebaya') ||
        lower.contains('putri') ||
        lower.contains('wanita') ||
        lower.contains('kuthubaru')) {
      final kebaya = JavaneseClothingData.upperBodyItems.firstWhere(
        (i) => i.gender == GenderTarget.wanita,
        orElse: () => JavaneseClothingData.upperBodyItems.first,
      );
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Busana putri Keraton Kasunanan Surakarta menghadirkan keanggunan **Kebaya Kartini Sutra/Beludru** dan **Kebaya Kutu Baru**. Dipadukan dengan stagen jumputan dan selendang sutra prada, busana ini memancarkan kelembutan budi pekerti wanita Jawa yang luwes dan anggun.',
        timestamp: DateTime.now(),
        sourceReference:
            'Rujukan: Busana Adat Kagungan Dalem Karaton Kasunanan',
        action: AssistantAction(
          type: 'garment_detail',
          title: kebaya.name,
          description: kebaya.javaneseScript,
          targetGarment: kebaya,
        ),
      );
    }

    // Kasus Umum: Rekomendasi Formal / Beskap
    final formalOutfit = JavaneseClothingData.curatedOutfits.first;
    return AssistantChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AssistantRole.assistant,
      text:
          'Berdasarkan khasanah busana tradisional Jawa Tengah, setelan **${formalOutfit.title}** adalah pilihan utama untuk acara resmi kebudayaan.\n\nTerdiri atas atasan Beskap dengan kancing kencana, Jarik Wiru batik sogan, Blangkon Mondholan Trepes, dan disempurnakan oleh pusaka Keris Ladrang di pinggang belakang.',
      timestamp: DateTime.now(),
      sourceReference: 'Rujukan: Tata Busana Adat Priyayi Jawa Tengah',
      action: AssistantAction(
        type: 'outfit_recommendation',
        title: formalOutfit.title,
        description: formalOutfit.javaneseScript,
        targetOutfit: formalOutfit,
      ),
    );
  }
}
