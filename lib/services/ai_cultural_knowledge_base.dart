import '../features/explore/explore_data.dart';
import '../features/explore/explore_models.dart';
import '../features/fashion/data/javanese_clothing_data.dart';
import '../features/fashion/models/javanese_clothing_models.dart';
import 'ai_cultural_assistant_service.dart';

/// Mesin Pengetahuan & Pencarian Kurasi Budaya Jawa Tengah (Cultural RAG Helper)
///
/// Mengindeks seluruh data busana adat, motif batik, setelan kurasi keraton,
/// kabupaten budaya Jawa Tengah, dan kuis historis untuk:
/// 1) Menyuntikkan konteks faktual (RAG grounding) ke dalam prompt AI live agar akurat.
/// 2) Menyediakan jawaban lokal cerdas & rujukan interaktif saat mode offline atau jeda kuota.
class AiCulturalKnowledgeBase {
  AiCulturalKnowledgeBase._();

  static const Set<String> _stopWords = {
    'yang',
    'dan',
    'atau',
    'di',
    'ke',
    'dari',
    'ini',
    'itu',
    'untuk',
    'pada',
    'dengan',
    'adalah',
    'apa',
    'bagaimana',
    'kapan',
    'siapa',
    'mengapa',
    'kenapa',
    'jelaskan',
    'tentang',
    'filosofi',
    'makna',
    'pakem',
    'adat',
    'jawa',
    'tengah',
    'busana',
    'baju',
    'pakaian',
    'rekomendasi',
    'tolong',
    'saya',
    'aku',
    'kamu',
    'bisa',
    'carikan',
  };

  /// Ekstrak token pencarian bernilai dari pertanyaan pengguna dengan normalisasi sinonim.
  static List<String> _extractTokens(String query) {
    final normalized = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll('manten', 'pengantin')
        .replaceAll('nikah', 'pengantin')
        .replaceAll('wedding', 'pengantin')
        .replaceAll('ijab', 'pengantin')
        .replaceAll('solo', 'surakarta solo')
        .replaceAll('jogja', 'yogyakarta')
        .replaceAll('putri', 'wanita putri')
        .replaceAll('kakung', 'pria kakung')
        .replaceAll('kutubaru', 'kutu baru');

    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !_stopWords.contains(w))
        .toSet()
        .toList();
    return tokens;
  }

  static int _scoreText(String queryLower, List<String> tokens, String corpus) {
    final lowerCorpus = corpus.toLowerCase();
    var score = 0;

    if (queryLower.length >= 4 && lowerCorpus.contains(queryLower)) {
      score += 12;
    }

    for (final token in tokens) {
      if (lowerCorpus.contains(token)) {
        score += token.length >= 6 ? 4 : 3;
      }
    }
    return score;
  }

  /// Membangun konteks RAG singkat dari katalog JAVARA agar AI live tidak berhalusinasi.
  static String buildRagContext(String query, {int maxEntries = 3}) {
    final queryLower = query.trim().toLowerCase();
    final tokens = _extractTokens(query);

    final scored = <({int score, String summary})>[];

    for (final outfit in JavaneseClothingData.curatedOutfits) {
      final corpus =
          '${outfit.title} ${outfit.collectionCategory} ${outfit.region.title} ${outfit.summary} ${outfit.culturalPhilosophy} ${outfit.etiquetteRules}';
      final s = _scoreText(queryLower, tokens, corpus);
      if (s > 0) {
        scored.add((
          score: s + 2,
          summary:
              '- Setelan "${outfit.title}" (${outfit.region.title}, ${outfit.era}): ${outfit.summary} Filosofi: ${outfit.culturalPhilosophy} Tatakrama: ${outfit.etiquetteRules}',
        ));
      }
    }

    for (final item in JavaneseClothingData.clothingItems) {
      final corpus =
          '${item.name} ${item.category.label} ${item.gender.label} ${item.region.title} ${item.material} ${item.philosophicalMeaning} ${item.cuttingAndConstruction}';
      final s = _scoreText(queryLower, tokens, corpus);
      if (s > 0) {
        scored.add((
          score: s,
          summary:
              '- Busana "${item.name}" (${item.category.label}, ${item.region.title}): Bahan ${item.material}. Filosofi: ${item.philosophicalMeaning} Konstruksi: ${item.cuttingAndConstruction}',
        ));
      }
    }

    for (final motif in JavaneseClothingData.batikMotifs) {
      final corpus =
          '${motif.name} batik motif ${motif.category} ${motif.meaning} ${motif.historicalUsage}';
      final s = _scoreText(queryLower, tokens, corpus);
      if (s > 0) {
        scored.add((
          score: s + 1,
          summary:
              '- Motif Batik "${motif.name}" (${motif.isLarangan ? "Batik Larangan Awisan Dalem" : motif.category}): ${motif.meaning} Penggunaan: ${motif.historicalUsage}',
        ));
      }
    }

    for (final regency in centralJavaRegencies) {
      final corpus =
          '${regency.name} ${regency.title} ${regency.specialty} ${regency.landmark} ${regency.description}';
      final s = _scoreText(queryLower, tokens, corpus);
      if (s > 0) {
        scored.add((
          score: s,
          summary:
              '- Wilayah Budaya ${regency.name} (${regency.title}): ${regency.description} Ikon: ${regency.landmark}. Kekhasan: ${regency.specialty}.',
        ));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.isEmpty) return '';

    return scored.take(maxEntries).map((e) => e.summary).join('\n');
  }

  /// Mengetahui apakah pertanyaan memiliki kecocokan kuat di katalog busana lokal.
  static bool hasStrongCatalogMatch(String query) {
    final queryLower = query.trim().toLowerCase();
    final tokens = _extractTokens(query);
    if (tokens.isEmpty) return false;

    for (final outfit in JavaneseClothingData.curatedOutfits) {
      final corpus =
          '${outfit.title} ${outfit.summary} ${outfit.culturalPhilosophy}';
      if (_scoreText(queryLower, tokens, corpus) >= 6) return true;
    }
    for (final item in JavaneseClothingData.clothingItems) {
      final corpus = '${item.name} ${item.philosophicalMeaning} ${item.material}';
      if (_scoreText(queryLower, tokens, corpus) >= 6) return true;
    }
    for (final motif in JavaneseClothingData.batikMotifs) {
      final corpus = '${motif.name} ${motif.meaning}';
      if (_scoreText(queryLower, tokens, corpus) >= 6) return true;
    }
    return false;
  }

  /// Menghasilkan jawaban kurasi lokal cerdas dari seluruh pustaka data JAVARA
  /// (plus ringkasan live Wikipedia Indonesia bila tersedia).
  static AssistantChatMessage generateLocalResponse(
    String query, {
    String? wikipediaTitle,
    String? wikipediaSummary,
    int? publicCooldownSeconds,
  }) {
    final lower = query.toLowerCase();
    final tokens = _extractTokens(query);

    // 1. Jika ada data live Wikipedia & pertanyaan tidak spesifik hanya ke 1 item busana,
    //    gabungkan wawasan ensiklopedia langsung dengan konteks aksi JAVARA.
    if (wikipediaSummary != null &&
        wikipediaSummary.trim().isNotEmpty &&
        !hasStrongCatalogMatch(query)) {
      final titleLabel = (wikipediaTitle ?? '').trim();
      final header = titleLabel.isNotEmpty ? '**$titleLabel**\n\n' : '';
      final action = resolveContextualAction(query, wikipediaSummary);
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text: '$header${wikipediaSummary.trim()}',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Live Pengetahuan Budaya · Wikipedia Indonesia & Pustaka JAVARA',
          publicCooldownSeconds,
        ),
        action: action,
      );
    }

    // 2. Kasus Kurasi Inti Busana Pengantin / Pernikahan Ageng
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
        sourceReference: _withCooldownNote(
          'Rujukan: Serat Tatacara Karaton Surakarta & Pawiyatan Kabudayan',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'outfit_recommendation',
          title: outfit.title,
          description: '${outfit.region.title} · ${outfit.socialContext}',
          targetOutfit: outfit,
        ),
      );
    }

    // 3. Cari kecocokan tertinggi di antara Setelan Kurasi, Satuan Busana, Motif Batik, Wilayah, & Kuis
    TraditionalOutfit? bestOutfit;
    var bestOutfitScore = 0;
    for (final outfit in JavaneseClothingData.curatedOutfits) {
      final corpus =
          '${outfit.title} ${outfit.collectionCategory} ${outfit.region.title} ${outfit.summary} ${outfit.culturalPhilosophy}';
      final s = _scoreText(lower, tokens, corpus);
      if (s > bestOutfitScore) {
        bestOutfitScore = s;
        bestOutfit = outfit;
      }
    }

    ClothingItem? bestItem;
    var bestItemScore = 0;
    for (final item in JavaneseClothingData.clothingItems) {
      final corpus =
          '${item.name} ${item.category.label} ${item.region.title} ${item.material} ${item.philosophicalMeaning} ${item.cuttingAndConstruction}';
      final s = _scoreText(lower, tokens, corpus);
      if (s > bestItemScore) {
        bestItemScore = s;
        bestItem = item;
      }
    }

    BatikMotif? bestMotif;
    var bestMotifScore = 0;
    for (final motif in JavaneseClothingData.batikMotifs) {
      final corpus =
          '${motif.name} ${motif.category} ${motif.meaning} ${motif.historicalUsage}';
      final s = _scoreText(lower, tokens, corpus);
      if (s > bestMotifScore) {
        bestMotifScore = s;
        bestMotif = motif;
      }
    }

    RegencyInfo? bestRegency;
    var bestRegencyScore = 0;
    for (final regency in centralJavaRegencies) {
      final corpus =
          '${regency.name} ${regency.title} ${regency.specialty} ${regency.landmark} ${regency.description}';
      final s = _scoreText(lower, tokens, corpus);
      if (s > bestRegencyScore) {
        bestRegencyScore = s;
        bestRegency = regency;
      }
    }

    // Pilih kandidat spesifik tertinggi terlebih dahulu (Motif & Setelan)
    if (bestMotif != null &&
        bestMotifScore >= bestItemScore &&
        bestMotifScore >= bestOutfitScore &&
        bestMotifScore >= 5) {
      final relatedGarment = JavaneseClothingData.lowerBodyItems.firstWhere(
        (g) => g.name.toLowerCase().contains(
            bestMotif!.name.split(' ').first.toLowerCase()),
        orElse: () => JavaneseClothingData.lowerBodyItems.first,
      );
      final laranganTag = bestMotif.isLarangan
          ? ' *(Motif Larangan / Awisan Dalem)*'
          : '';
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            '**Batik ${bestMotif.name}** (${bestMotif.javaneseScript})$laranganTag\n\n'
            '• **Filosofi:** ${bestMotif.meaning}\n'
            '• **Penggunaan Adat:** ${bestMotif.historicalUsage}',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: Ensiklopedia Batik Adiluhung Keraton Kasunanan',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'batik_motif',
          title: relatedGarment.name,
          description: '${bestMotif.category} · ${relatedGarment.region.title}',
          targetGarment: relatedGarment,
        ),
      );
    }

    if (bestOutfit != null &&
        bestOutfitScore >= bestItemScore &&
        bestOutfitScore >= 6) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            '**${bestOutfit.title}** (${bestOutfit.region.title} · ${bestOutfit.era})\n\n'
            '${bestOutfit.summary}\n\n'
            '• **Filosofi Budaya:** ${bestOutfit.culturalPhilosophy}\n'
            '• **Tatakrama Adat:** ${bestOutfit.etiquetteRules}',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: ${bestOutfit.historicalSources}',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'outfit_recommendation',
          title: bestOutfit.title,
          description: '${bestOutfit.region.title} · ${bestOutfit.socialContext}',
          targetOutfit: bestOutfit,
        ),
      );
    }

    if (bestItem != null && lower.contains(bestItem.name.toLowerCase())) {
      return _buildItemResponse(bestItem, publicCooldownSeconds);
    }

    // 4. Kurasi kata kunci klasik utama (Batik, Blangkon, Keris, Kebaya)
    if (lower.contains('batik') ||
        lower.contains('parang') ||
        lower.contains('motif') ||
        lower.contains('jarik')) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Motif batik pada busana Jawa memiliki tingkatan pakem yang sangat adiluhung:\n\n'
            '• **Parang Barong:** Diciptakan oleh Sultan Agung Hanyakrakusuma, melambangkan ombak samudera dan tekad ksatria pantang menyerah (batik larangan/*awisan dalem*).\n'
            '• **Sido Asih & Sido Mukti:** Melambangkan doa agar pemakainya dilimpahi cinta kasih dan keluhuran budi pekerti.\n'
            '• **Truntum:** Bermakna cinta kasih yang bersemi kembali, dikenakan oleh orang tua mempelai.',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: Ensiklopedia Batik Adiluhung Keraton Kasunanan',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'batik_motif',
          title: 'Batik Parang Barong Sogan',
          description:
              'Pola diagonal miring ombak karang laut selatan · Surakarta',
          targetGarment: JavaneseClothingData.lowerBodyItems.first,
        ),
      );
    }

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
        sourceReference: _withCooldownNote(
          'Rujukan: Makna Simbolik Busana Adat Pria Jawi Jangkep',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'garment_detail',
          title: blangkon.name,
          description: blangkon.javaneseScript,
          targetGarment: blangkon,
        ),
      );
    }

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
            'Dalam kelengkapan Jawi Jangkep, **Keris Gaya Ladrang Surakarta** adalah warangka utama untuk pahargyan resmi dan sowan keraton. Bentuk warangka menyerupai kapal yang berlayar gagah di samudra, melambangkan kesiapan ksatria menjaga kehormatan keluarga.',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: Kawruh Kagunan Dhuwung Surakarta',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'garment_detail',
          title: keris.name,
          description: keris.javaneseScript,
          targetGarment: keris,
        ),
      );
    }

    if (lower.contains('kebaya') ||
        lower.contains('putri') ||
        lower.contains('wanita') ||
        lower.contains('kuthubaru') ||
        lower.contains('kutu baru')) {
      final kebaya = JavaneseClothingData.upperBodyItems.firstWhere(
        (i) => i.gender == GenderTarget.wanita,
        orElse: () => JavaneseClothingData.upperBodyItems.first,
      );
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Busana putri Keraton Kasunanan Surakarta menghadirkan keanggunan **Kebaya Kartini Sutra/Beludru** dan **Kebaya Kutu Baru**. Dipadukan dengan stagen jumputan dan selendang sutra prada, busana ini memancarkan kelembutan budi pekerti wanita Jawa.',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: Busana Adat Kagungan Dalem Karaton Kasunanan',
          publicCooldownSeconds,
        ),
        action: AssistantAction(
          type: 'garment_detail',
          title: kebaya.name,
          description: kebaya.javaneseScript,
          targetGarment: kebaya,
        ),
      );
    }

    if (bestItem != null && bestItemScore >= 4) {
      return _buildItemResponse(bestItem, publicCooldownSeconds);
    }

    if (bestRegency != null && bestRegencyScore >= 4) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            '**${bestRegency.name} — ${bestRegency.title}**\n\n'
            '${bestRegency.description}\n\n'
            '• **Landmark Utama:** ${bestRegency.landmark}\n'
            '• **Warisan Khas:** ${bestRegency.specialty}',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Rujukan: Peta Budaya & Khasanah Jawa Tengah JAVARA',
          publicCooldownSeconds,
        ),
      );
    }

    if (wikipediaSummary != null && wikipediaSummary.trim().isNotEmpty) {
      final titleLabel = (wikipediaTitle ?? '').trim();
      final header = titleLabel.isNotEmpty ? '**$titleLabel**\n\n' : '';
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text: '$header${wikipediaSummary.trim()}',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Live Pengetahuan Budaya · Wikipedia Indonesia & Pustaka JAVARA',
          publicCooldownSeconds,
        ),
        action: resolveContextualAction(query, wikipediaSummary),
      );
    }

    // 5. Jika sapaan ringan atau topik umum di luar kurasi pakaian
    if (lower.contains('halo') ||
        lower.contains('hai') ||
        lower.contains('selamat') ||
        lower.contains('siapa kamu') ||
        lower.contains('terima kasih') ||
        lower.contains('matur nuwun')) {
      return AssistantChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: AssistantRole.assistant,
        text:
            'Sugeng rawuh! Kula **Abdi Pakar Busana JAVARA**, pendamping budaya Jawa Tengah Anda. '
            'Silakan tanyakan seputar *Beskap Jawi Jangkep*, *Kebaya Kartini*, filosofi *Batik Parang/Truntum*, pakem *Blangkon* & *Keris*, atau ketuk ikon kunci di pojok kanan atas untuk menautkan API Key AI pilihan Anda.',
        timestamp: DateTime.now(),
        sourceReference: _withCooldownNote(
          'Abdi Pakar Busana · Pustaka JAVARA',
          publicCooldownSeconds,
        ),
      );
    }

    // 6. Kasus Umum: Rekomendasi Formal / Beskap
    final formalOutfit = JavaneseClothingData.curatedOutfits.first;
    return AssistantChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AssistantRole.assistant,
      text:
          'Berdasarkan khasanah busana tradisional Jawa Tengah, setelan **${formalOutfit.title}** adalah pilihan utama untuk acara resmi kebudayaan.\n\nTerdiri atas atasan Beskap dengan kancing kencana, Jarik Wiru batik sogan, Blangkon Mondholan Trepes, dan disempurnakan oleh pusaka Keris Ladrang di pinggang belakang.',
      timestamp: DateTime.now(),
      sourceReference: _withCooldownNote(
        'Rujukan: Tata Busana Adat Priyayi Jawa Tengah',
        publicCooldownSeconds,
      ),
      action: AssistantAction(
        type: 'outfit_recommendation',
        title: formalOutfit.title,
        description: formalOutfit.javaneseScript,
        targetOutfit: formalOutfit,
      ),
    );
  }

  static AssistantChatMessage _buildItemResponse(
    ClothingItem item,
    int? publicCooldownSeconds,
  ) {
    final cleanMaterial = item.material.replaceFirst(RegExp(r'\.+$'), '');
    return AssistantChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AssistantRole.assistant,
      text:
          '**${item.name}** (${item.javaneseScript})\n'
          'Asal tradisi: ${item.region.title} · ${item.period}\n\n'
          '• **Makna Filosofis:** ${item.philosophicalMeaning}\n'
          '• **Bahan & Pemotongan:** $cleanMaterial. ${item.cuttingAndConstruction}',
      timestamp: DateTime.now(),
      sourceReference: _withCooldownNote(
        'Rujukan: ${item.references}',
        publicCooldownSeconds,
      ),
      action: AssistantAction(
        type: 'garment_detail',
        title: item.name,
        description: item.javaneseScript,
        targetGarment: item,
      ),
    );
  }

  static String _withCooldownNote(String base, int? cooldownSeconds) {
    if (cooldownSeconds != null && cooldownSeconds > 0) {
      return '$base · Jeda AI Publik ${cooldownSeconds}d (Ketuk ikon kunci untuk tanpa jeda)';
    }
    return base;
  }

  /// Menghubungkan teks pertanyaan & respons AI dengan kartu aksi interaktif JAVARA.
  static AssistantAction? resolveContextualAction(
      String query, String responseText) {
    final combined = '${query.toLowerCase()} ${responseText.toLowerCase()}';

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

    if (combined.contains('surjan') || combined.contains('lurik')) {
      final outfit = JavaneseClothingData.curatedOutfits.firstWhere(
        (o) => o.id.contains('surjan'),
        orElse: () => JavaneseClothingData.curatedOutfits.first,
      );
      return AssistantAction(
        type: 'outfit_recommendation',
        title: outfit.title,
        description: '${outfit.region.title} · ${outfit.socialContext}',
        targetOutfit: outfit,
      );
    }

    if (combined.contains('parang') ||
        combined.contains('kawung') ||
        combined.contains('truntum') ||
        combined.contains('sido mukti') ||
        combined.contains('sidomukti') ||
        combined.contains('sido asih') ||
        combined.contains('sidoasih') ||
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
}
