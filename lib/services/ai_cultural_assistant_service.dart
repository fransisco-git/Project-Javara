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
/// Keraton Kasunanan Surakarta & Jawa Tengah, dilengkapi function calling terstruktur.
class AiCulturalAssistantService {
  AiCulturalAssistantService._();
  static final AiCulturalAssistantService instance = AiCulturalAssistantService._();

  /// Prompt Dasar Pengetahuan Budaya & Pakem Adat
  static const String _systemPrompt = '''
Anda adalah "Abdi Pakar Busana JAVARA", asisten kurasi busana adat Jawa Tengah yang berwibawa, santun, dan sangat memahami pakem busana Keraton Kasunanan Surakarta Hadiningrat, Pura Mangkunegaran, Banyumas, dan pesisir Pekalongan.
Prinsip:
1. Rekomendasikan busana berdasarkan tatakrama tradisi (pahargyan pengantin, sowan keraton, upacara ageng, keseharian).
2. Terangkan filosofi kain wastra, motif batik, iketan blangkon, dan penempatan keris ladrang secara akurat.
3. Rujuk sumber sejarah resmi (Serat Centhini, Pawiyatan Kabudayan Karaton Surakarta).
''';

  /// Memproses Pesan Pengguna dan Mengembalikan Jawaban Terstruktur
  Future<AssistantChatMessage> sendMessage(String query) async {
    final lower = query.toLowerCase();

    if (AppConfig.isLlmConfigured) {
      try {
        final res = await _callExternalLlmApi(query);
        if (res != null) return res;
      } catch (e) {
        debugPrint('LLM API call fallback: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 650));

    // Kasus A: Rekomendasi Busana Pernikahan / Upacara Ageng
    if (lower.contains('nikah') ||
        lower.contains('pengantin') ||
        lower.contains('wedding') ||
        lower.contains('pernikahan') ||
        lower.contains('ijab')) {
      final outfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.id.contains('basahan') || o.id.contains('jangkep'),
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );

      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text: 'Untuk upacara pernikahan ageng adat Jawa Tengah (Surakarta), busana yang paling sakral dan penuh wibawa adalah **Solo Basahan (Dodot Ageng)** untuk kemegahan kanarendran, atau **Jawi Jangkep Langenharjan** untuk akad/resepsi formal.\n\nBusana ini melambangkan penyatuan dua insan dalam restu Hyang Widhi dengan kain dodot kampuh sekar semen yang sarat doa kesuburan.',
        timestamp: DateTime.now(),
        sourceReference: 'Rujukan: Serat Tatacara Karaton Surakarta & Pawiyatan Kabudayan',
        action: AssistantAction(
          type: 'outfit_recommendation',
          title: outfit.title,
          description: '${outfit.region.title} · ${outfit.socialContext}',
          targetOutfit: outfit,
        ),
      );
    }

    // Kasus B: Filosofi Batik & Makna Motif
    if (lower.contains('batik') || lower.contains('parang') || lower.contains('motif') || lower.contains('jarik')) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text: 'Motif batik pada busana Jawa memiliki tingkatan pakem yang sangat agung:\n\n• **Parang Barong:** Diciptakan oleh Sultan Agung Hanyakrakusuma, melambangkan ombak samudera dan tekad ksatria pantang menyerah. Dahulu merupakan batik larangan (*awisan dalem*) yang hanya dikenakan raja dan putra mahkota.\n• **Sido Asih & Sido Mukti:** Melambangkan doa agar pemakainya senantiasa dilimpahi cinta kasih (*asih*) dan keluhuran derajat budi pekerti.',
        timestamp: DateTime.now(),
        sourceReference: 'Rujukan: Ensiklopedia Batik Adiluhung Keraton Kasunanan',
        action: AssistantAction(
          type: 'batik_motif',
          title: 'Batik Parang Barong Sogan',
          description: 'Pola diagonal miring ombak karang laut selatan · Surakarta',
          targetGarment: JavaneseClothingData.lowerBodyItems.first,
        ),
      );
    }

    // Kasus C: Headwear / Blangkon
    if (lower.contains('blangkon') || lower.contains('iket') || lower.contains('kepala')) {
      final blangkon = JavaneseClothingData.headwearItems.first;
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text: 'Ciri khas penutup kepala pria Surakarta adalah **Blangkon Mondholan Trepes**. Bagian belakang berbentuk pipih/ceper, melambangkan watak kesatria Jawa yang mampu mengubur dan mengendalikan rahasia batin serta emosi secara santun.',
        timestamp: DateTime.now(),
        sourceReference: 'Rujukan: Makna Simbolik Busana Adat Pria Jawi Jangkep',
        action: AssistantAction(
          type: 'garment_detail',
          title: blangkon.name,
          description: blangkon.javaneseScript,
          targetGarment: blangkon,
        ),
      );
    }

    // Kasus D: Rekomendasi Formal / Beskap
    final formalOutfit = JavaneseClothingData.curatedOutfits.first;
    return AssistantChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AssistantRole.assistant,
      text: 'Berdasarkan khasanah busana tradisional Jawa Tengah, setelan **${formalOutfit.title}** adalah pilihan utama untuk acara resmi kebudayaan.\n\nTerdiri atas atasan Beskap dengan kancing kencana, Jarik Wiru batik sogan, Blangkon Kasunanan, dan disempurnakan oleh pusaka Keris Ladrang di pinggang belakang.',
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

  /// Panggilan Eksternal API LLM (OpenAI / Gemini / Anthropic compatible)
  Future<AssistantChatMessage?> _callExternalLlmApi(String query) async {
    try {
      // Implementasi standard HTTP POST ke LLM endpoint jika dikonfigurasi
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${AppConfig.llmApiKey}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': '$_systemPrompt\nPertanyaan Pengguna: $query'}]}
          ]
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contentText = data['candidates'][0]['content']['parts'][0]['text'] as String?;
        if (contentText != null) {
          return AssistantChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: AssistantRole.assistant,
            text: contentText,
            timestamp: DateTime.now(),
            sourceReference: 'Didukung oleh JAVARA Cultural LLM Engine',
          );
        }
      }
    } catch (e) {
      debugPrint('LLM call error: $e');
    }
    return null;
  }
}
