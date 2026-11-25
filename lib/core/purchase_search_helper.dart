import 'package:url_launcher/url_launcher.dart';

/// Membangun URL pencarian Google ter-encode untuk mencari tempat membeli item.
Uri buildPurchaseSearchUrl(String namaItem) {
  return Uri.https('www.google.com', '/search', {'q': 'beli $namaItem'});
}

/// Membuka pencarian Google untuk membeli [namaItem] di browser eksternal.
/// Tidak bergantung pada `canLaunchUrl`.
Future<bool> launchPurchaseSearch(String namaItem) async {
  final uri = buildPurchaseSearchUrl(namaItem);
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Membangun URL resmi Google Maps tanpa API key untuk lokasi budaya.
Uri buildGoogleMapsUrl(String placeQuery) {
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': placeQuery,
  });
}

/// Memetakan item budaya/busana ke query situs budaya yang akurat untuk Google Maps.
String resolveCulturalMapsQuery({
  required String itemId,
  required String title,
  String location = '',
  String region = '',
}) {
  final id = itemId.toLowerCase();
  final combined = '$id $title $location $region'.toLowerCase();

  if (id == 'kebaya_kartini_rembang') {
    return 'ANF sewa kebaya & MUA';
  }
  if (id == 'busana_pengantin_solo_basahan') {
    return 'BATIK PUTRA BENGAWAN batik kualitas premium-kampung batik Laweyan solo surakarta jawa tengah indonesia';
  }
  if (id == 'batik_tulis_solo' ||
      id == 'jarik_batik_parang_barong_solo' ||
      combined.contains('parang barong') ||
      combined.contains('batik tulis solo')) {
    return 'Kampung Batik Laweyan, Surakarta';
  }
  if (combined.contains('lasem')) {
    return 'Kampung Batik Lasem, Rembang, Jawa Tengah';
  }
  if (combined.contains('rembang')) {
    return 'Museum R.A. Kartini Rembang, Jawa Tengah';
  }
  if (combined.contains('jepara')) {
    return 'Museum R.A. Kartini Jepara, Jawa Tengah';
  }
  if (combined.contains('pekalongan')) {
    return 'Museum Batik Pekalongan, Jawa Tengah';
  }
  if (combined.contains('yogyakarta') || combined.contains('jogja')) {
    return 'Keraton Ngayogyakarta Hadiningrat, Yogyakarta';
  }
  if (combined.contains('banyumas')) {
    return 'Museum Wayang Sendang Mas Banyumas, Jawa Tengah';
  }
  if (combined.contains('klaten') || combined.contains('lurik')) {
    return 'Sentra Tenun Lurik Pedan, Klaten, Jawa Tengah';
  }
  if (combined.contains('surakarta') || combined.contains('solo')) {
    return 'Keraton Kasunanan Surakarta Hadiningrat, Surakarta';
  }

  final fallbackPlace = location.trim().isNotEmpty
      ? location.trim()
      : (region.trim().isNotEmpty ? region.trim() : title.trim());
  return '$fallbackPlace, Indonesia';
}

/// Membuka lokasi budaya di aplikasi Google Maps eksternal.
/// Tidak bergantung pada `canLaunchUrl`.
Future<bool> launchGoogleMaps(String placeQuery) async {
  final uri = buildGoogleMapsUrl(placeQuery);
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
