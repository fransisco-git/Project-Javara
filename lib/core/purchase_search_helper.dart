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
