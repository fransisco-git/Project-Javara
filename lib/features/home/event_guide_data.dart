import '../../data/culture_items.dart';
import '../fashion/data/javanese_clothing_data.dart';
import '../fashion/models/javanese_clothing_models.dart';

/// Data konstanta Panduan Acara (teks Pakem & Etika + pemetaan ID busana).
/// Disimpan terpisah agar mudah disunting tanpa menyentuh kode UI Beranda.
class EventGuideItem {
  const EventGuideItem({
    required this.id,
    required this.title,
    required this.pakemText,
    required this.itemIds,
  });

  final String id;
  final String title;
  final String pakemText;
  final List<String> itemIds;
}

const List<EventGuideItem> eventGuideItems = [
  EventGuideItem(
    id: 'pernikahan',
    title: 'Pernikahan',
    pakemText:
        'Mempelai umumnya memakai busana pengantin pakem seperti Solo Basahan. Motif Sido Mukti lazim dikenakan kedua mempelai, sedangkan Truntum dikenakan orang tua pengantin.',
    itemIds: [
      'busana_pengantin_solo_basahan',
      'jarik_batik_sidomukti_solo',
      'jarik_batik_truntum_solo',
    ],
  ),
  EventGuideItem(
    id: 'kondangan',
    title: 'Kondangan',
    pakemText:
        'Pilih kebaya atau beskap yang sopan dengan kain batik klasik. Hindari motif larangan keraton seperti Parang Barong.',
    itemIds: [
      'kebaya_kutubaru_solo',
      'beskap_landhung_solo',
    ],
  ),
  EventGuideItem(
    id: 'wisuda',
    title: 'Wisuda',
    pakemText:
        'Kebaya Kartini atau Kutu Baru, atau beskap yang rapi, dipadukan dengan kain batik klasik. Hindari motif larangan keraton.',
    itemIds: [
      'kebaya_kartini_rembang',
      'beskap_landhung_solo',
    ],
  ),
  EventGuideItem(
    id: 'upacara_adat',
    title: 'Upacara Adat',
    pakemText:
        'Kenakan busana Jawi Jangkep lengkap dengan ricikan adat (blangkon, keris, sabuk), mengikuti pakem keraton setempat.',
    itemIds: [
      'beskap_jawi_jangkep_solo',
    ],
  ),
];

/// Hasil resolusi item rekomendasi dari `culture_items.dart` atau `JavaneseClothingData`.
class ResolvedEventRecommendation {
  const ResolvedEventRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.cultureItem,
    this.clothingItem,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final CultureItem? cultureItem;
  final ClothingItem? clothingItem;
}

/// Menyelesaikan daftar ID item menjadi rekomendasi nyata dari data yang sudah ada.
List<ResolvedEventRecommendation> resolveEventRecommendations(
  EventGuideItem guide,
) {
  final allCultureItems = [...popularItems, ...pickedItems];
  final results = <ResolvedEventRecommendation>[];

  for (final id in guide.itemIds) {
    CultureItem? matchedCulture;
    for (final item in allCultureItems) {
      if (item.id == id) {
        matchedCulture = item;
        break;
      }
    }
    if (matchedCulture != null) {
      results.add(
        ResolvedEventRecommendation(
          id: matchedCulture.id,
          title: matchedCulture.title,
          subtitle: matchedCulture.meta,
          imagePath: 'assets/images/${matchedCulture.image}',
          cultureItem: matchedCulture,
        ),
      );
      continue;
    }

    final matchedClothing = JavaneseClothingData.getItemById(id);
    if (matchedClothing != null) {
      results.add(
        ResolvedEventRecommendation(
          id: matchedClothing.id,
          title: matchedClothing.name,
          subtitle:
              '${matchedClothing.region.title} · ${matchedClothing.category.label}',
          imagePath: matchedClothing.imageAsset,
          clothingItem: matchedClothing,
        ),
      );
    }
  }

  return results;
}
