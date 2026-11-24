import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/javanese_wardrobe_screen.dart';
import '../fashion/screens/my_heritage_collection_screen.dart';

/// Tab Profil JAVARA - Pengalaman Profil Terpadu Busana Adat Jawa Tengah.
/// Fokus 100% pada busana adat: identitas pengguna, aktivitas sewa & pesanan,
/// ukuran tubuh (My Size), preferensi aksara/audio, dan panduan wastra.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.onOpenTab});

  final ValueChanged<int>? onOpenTab;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Preferensi
  bool _showJavaneseScript = true;
  bool _ambientGamelan = true;

  // Ukuran Busana (My Size)
  String _sizeTop = 'L (LD 98 cm)';
  String _sizeHead = 'No. 7 (57 cm)';
  String _sizeJarik = 'Standar (220 cm)';

  // Data Pengguna
  bool _isGuest = false;
  String _userName = 'Raden Mas Aryo';
  String _userEmail = 'aryo.kusumo@javara.id';
  String _userPhone = '+62 812-3456-7890';
  String _userAddress = 'Jl. Slamet Riyadi No. 42, Surakarta, Jawa Tengah';

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final authUser = await AuthService.instance.currentUser();
    final isGuest = (authUser?.isGuest ?? false) || (prefs.getBool('javara_is_guest') ?? false);

    if (mounted) {
      setState(() {
        _isGuest = isGuest;
        _showJavaneseScript = prefs.getBool('javara_pref_aksara') ?? true;
        _ambientGamelan = prefs.getBool('javara_pref_gamelan') ?? true;

        _sizeTop = prefs.getString('javara_size_top') ?? 'L (LD 98 cm)';
        _sizeHead = prefs.getString('javara_size_head') ?? 'No. 7 (57 cm)';
        _sizeJarik = prefs.getString('javara_size_jarik') ?? 'Standar (220 cm)';

        if (_isGuest) {
          _userName = prefs.getString('javara_profile_name') ?? 'Tamu JAVARA';
          _userEmail = prefs.getString('javara_profile_email') ?? 'tamu.budaya@javara.id';
          _userPhone = prefs.getString('javara_profile_phone') ?? '-';
          _userAddress = prefs.getString('javara_profile_address') ?? 'Mode Tamu (Belum ada alamat)';
        } else {
          _userName = prefs.getString('javara_profile_name') ?? (authUser?.name ?? 'Raden Mas Aryo');
          _userEmail = prefs.getString('javara_profile_email') ?? (authUser?.email ?? 'aryo.kusumo@javara.id');
          _userPhone = prefs.getString('javara_profile_phone') ?? '+62 812-3456-7890';
          _userAddress = prefs.getString('javara_profile_address') ?? 'Jl. Slamet Riyadi No. 42, Surakarta, Jawa Tengah';
        }
      });
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showSnack(String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFDFB76C), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: JText.serif(13, color: const Color(0xFFFAF6EE), weight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E2019),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x55DFB76C), width: 0.8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x44B08D57), width: 1.0),
        ),
        title: Text(
          _isGuest ? 'Keluar dari Mode Tamu?' : 'Keluar dari JAVARA?',
          style: JText.serif(
            18,
            weight: FontWeight.w700,
            color: const Color(0xFF382315),
          ),
        ),
        content: Text(
          _isGuest
              ? 'Anda akan dialihkan kembali ke layar awal dan sesi tamu Anda akan direset.'
              : 'Seluruh pesanan, data ukuran busana, dan koleksi setelan Anda tetap tersimpan dengan aman.',
          style: JText.serif(13.5, color: const Color(0xFF5C4738), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: JText.serif(13, color: const Color(0xFF7D6C5D), weight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5603A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Ya, Keluar',
              style: JText.serif(
                13,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      fadeSlideRoute(const LoginScreen()),
      (_) => false,
    );
  }

  /// 1. Modal Edit Profil & Alamat Pengiriman
  void _openEditProfileModal(BuildContext context, {bool isAddressOnly = false}) {
    HapticFeedback.lightImpact();
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final addressCtrl = TextEditingController(text: _userAddress);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFCCB2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAddressOnly ? 'Alamat Pengiriman Busana' : 'Ubah Data Diri & Alamat',
                        style: JText.serif(18, weight: FontWeight.w700, color: const Color(0xFF382315)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF7D6C5D)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (!isAddressOnly) ...[
                  Text('Nama Lengkap', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: JText.serif(14, color: const Color(0xFF382315)),
                    decoration: _inputDecoration('Contoh: Raden Mas Aryo', Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 14),
                  Text('Nomor Telepon / WhatsApp', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: JText.serif(14, color: const Color(0xFF382315)),
                    decoration: _inputDecoration('+62 ...', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 14),
                ],
                Text('Alamat Lengkap Pengiriman / Fitting', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
                const SizedBox(height: 6),
                TextField(
                  controller: addressCtrl,
                  maxLines: 3,
                  style: JText.serif(14, color: const Color(0xFF382315)),
                  decoration: _inputDecoration('Nama jalan, nomor rumah, kelurahan, kota/kabupaten', Icons.location_on_outlined),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final n = nameCtrl.text.trim();
                      final p = phoneCtrl.text.trim();
                      final a = addressCtrl.text.trim();
                      setState(() {
                        if (n.isNotEmpty && !isAddressOnly) _userName = n;
                        if (p.isNotEmpty && !isAddressOnly) _userPhone = p;
                        if (a.isNotEmpty) _userAddress = a;
                      });
                      if (!isAddressOnly) {
                        _savePreference('javara_profile_name', _userName);
                        _savePreference('javara_profile_phone', _userPhone);
                      }
                      _savePreference('javara_profile_address', _userAddress);
                      Navigator.of(ctx).pop();
                      _showSnack('Data profil dan alamat berhasil diperbarui.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF382315),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Simpan Perubahan', style: JText.serif(14, weight: FontWeight.w700, color: const Color(0xFFFFDF9E))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFB08D57), size: 20),
      hintText: hint,
      hintStyle: JText.serif(13, color: const Color(0xFF9E8D7D)),
      filled: true,
      fillColor: const Color(0xFFFFFDF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEADBCA))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEADBCA))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFB08D57), width: 1.2)),
    );
  }

  /// 2. Modal Pesanan & Sewa Busana Saya
  void _openOrdersModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDFCCB2), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pesanan & Sewa Saya', style: JText.serif(20, weight: FontWeight.w700, color: const Color(0xFF382315))),
                          Text('Kelola sewa busana aktif & pengiriman wastra', style: JText.serif(12, color: const Color(0xFF7D6C5D))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF5C4738)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFEADBCA), height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    // Item 1: Sewa Aktif
                    _buildOrderItemCard(
                      badgeText: 'SEWA AKTIF',
                      badgeColor: const Color(0xFF4A6B48),
                      title: 'Beskap Jawi Jangkep Kasunanan Solo',
                      category: 'Sewa 3 Hari • Paket Busana Pengantin Lengkap',
                      priceText: 'Rp 450.000 / paket',
                      statusDesc: 'Batas Pengembalian: 24 Nov 2026 (Pukul 18.00 WIB)',
                      vendorName: 'Sanggar Busana Keraton Surakarta',
                      actionLabel: 'Hubungi Penata Busana',
                      onAction: () => _showSnack('Menghubungi Sanggar Keraton via WhatsApp...'),
                    ),
                    const SizedBox(height: 14),
                    // Item 2: Pengiriman
                    _buildOrderItemCard(
                      badgeText: 'DALAM PENGIRIMAN',
                      badgeColor: const Color(0xFFB5603A),
                      title: 'Kebaya Kartini Beludru Sulam Emas Jepara',
                      category: 'Beli Wastra • Ukuran L (Sesuai My Size)',
                      priceText: 'Rp 820.000 (Lunas)',
                      statusDesc: 'Kurir: JNE Regular (Resi: JVR-882910JTG)',
                      vendorName: 'Paguyuban Pengrajin Bordir Jepara',
                      actionLabel: 'Lacak Paket Busana',
                      onAction: () => _showSnack('Nomor resi JVR-882910JTG tersalin ke papan klip.'),
                    ),
                    const SizedBox(height: 14),
                    // Item 3: Riwayat Selesai
                    _buildOrderItemCard(
                      badgeText: 'SELESAI',
                      badgeColor: const Color(0xFF7D6C5D),
                      title: 'Kain Jarik Batik Tulis Parang Barong',
                      category: 'Sewa Acara Adat • Dikembalikan Tepat Waktu',
                      priceText: 'Rp 200.000 (Selesai)',
                      statusDesc: 'Status Deposit: Rp 100.000 telah dikembalikan penuh',
                      vendorName: 'Pusat Batik Laweyan Solo',
                      actionLabel: 'Sewa Kembali',
                      onAction: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(fadeSlideRoute(const ClothingCatalogScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemCard({
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String category,
    required String priceText,
    required String statusDesc,
    required String vendorName,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEADBCA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C382315),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 0.8),
                ),
                child: Text(
                  badgeText,
                  style: JText.serif(10, weight: FontWeight.w700, color: badgeColor),
                ),
              ),
              Text(
                vendorName,
                style: JText.serif(11, color: const Color(0xFF8C7B6D)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4ECE0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCA)),
                ),
                child: const Icon(Icons.checkroom_rounded, color: Color(0xFFB08D57), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: JText.serif(14.5, weight: FontWeight.w700, color: const Color(0xFF382315)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(category, style: JText.serif(11.5, color: const Color(0xFF7D6C5D))),
                    const SizedBox(height: 4),
                    Text(priceText, style: JText.serif(13, weight: FontWeight.w700, color: const Color(0xFFB08D57))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFB08D57)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusDesc,
                    style: JText.serif(11, color: const Color(0xFF5C4738)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFB08D57), width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                actionLabel,
                style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF382315)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Modal Edit Ukuran Busana Saya (My Size)
  void _openEditSizeModal(BuildContext context) {
    HapticFeedback.lightImpact();
    String tempTop = _sizeTop;
    String tempHead = _sizeHead;
    String tempJarik = _sizeJarik;

    final topOptions = ['S (LD 90 cm)', 'M (LD 94 cm)', 'L (LD 98 cm)', 'XL (LD 104 cm)', 'XXL (LD 110 cm)'];
    final headOptions = ['No. 5 (55 cm)', 'No. 6 (56 cm)', 'No. 7 (57 cm)', 'No. 8 (58 cm)', 'No. 9 (59 cm)', 'No. 10 (60 cm)'];
    final jarikOptions = ['Standar (220 cm)', 'Panjang (250 cm)', 'Jumbo (280 cm)'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDFCCB2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ubah Ukuran Busana (My Size)', style: JText.serif(18, weight: FontWeight.w700, color: const Color(0xFF382315)), overflow: TextOverflow.ellipsis),
                        Text('Ukuran ini dipakai otomatis saat jahit & sewa', style: JText.serif(12, color: const Color(0xFF7D6C5D))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF7D6C5D)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Ukuran Baju / Beskap / Kebaya (Lingkar Dada)', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topOptions.map((opt) {
                  final sel = tempTop == opt;
                  return ChoiceChip(
                    label: Text(opt, style: JText.serif(11.5, weight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF382315))),
                    selected: sel,
                    selectedColor: const Color(0xFF382315),
                    backgroundColor: const Color(0xFFFFFDF9),
                    side: BorderSide(color: sel ? const Color(0xFF382315) : const Color(0xFFEADBCA)),
                    onSelected: (val) {
                      if (val) setModalState(() => tempTop = opt);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Nomor Blangkon (Lingkar Kepala)', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: headOptions.map((opt) {
                  final sel = tempHead == opt;
                  return ChoiceChip(
                    label: Text(opt, style: JText.serif(11.5, weight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF382315))),
                    selected: sel,
                    selectedColor: const Color(0xFFB08D57),
                    backgroundColor: const Color(0xFFFFFDF9),
                    side: BorderSide(color: sel ? const Color(0xFFB08D57) : const Color(0xFFEADBCA)),
                    onSelected: (val) {
                      if (val) setModalState(() => tempHead = opt);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Panjang Kain Jarik', style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF5C4738))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: jarikOptions.map((opt) {
                  final sel = tempJarik == opt;
                  return ChoiceChip(
                    label: Text(opt, style: JText.serif(11.5, weight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF382315))),
                    selected: sel,
                    selectedColor: const Color(0xFF5C4738),
                    backgroundColor: const Color(0xFFFFFDF9),
                    side: BorderSide(color: sel ? const Color(0xFF5C4738) : const Color(0xFFEADBCA)),
                    onSelected: (val) {
                      if (val) setModalState(() => tempJarik = opt);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sizeTop = tempTop;
                      _sizeHead = tempHead;
                      _sizeJarik = tempJarik;
                    });
                    _savePreference('javara_size_top', _sizeTop);
                    _savePreference('javara_size_head', _sizeHead);
                    _savePreference('javara_size_jarik', _sizeJarik);
                    Navigator.of(ctx).pop();
                    _showSnack('Ukuran busana Anda berhasil diselaraskan.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF382315),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Simpan Ukuran Saya', style: JText.serif(14, weight: FontWeight.w700, color: const Color(0xFFFFDF9E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4. Modal Panduan Ukur Tradisional
  void _openSizeGuideModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.90,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
          ),
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDFCCB2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Panduan Ukur Busana Adat', style: JText.serif(18, weight: FontWeight.w700, color: const Color(0xFF382315)), overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF7D6C5D)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGuideSection(
                number: '1',
                title: 'Lingkar Dada (Beskap & Kebaya)',
                desc: 'Lilitkan pita meteran melingkari dada tepat di atas dada. Tarik pas lalu beri kelonggaran 2 jari (sekitar 3-4 cm) agar tetap leluasa saat bersila atau bernapas dalam busana adat.',
              ),
              const SizedBox(height: 14),
              _buildGuideSection(
                number: '2',
                title: 'Nomor Blangkon (Lingkar Kepala)',
                desc: 'Ukur keliling kepala tepat 1 cm di atas alis mata dan daun telinga. Nomor blangkon dihitung dari keliling kepala (cm) dikurangi 50 (contoh: 57 cm = Blangkon No. 7).',
              ),
              const SizedBox(height: 14),
              _buildGuideSection(
                number: '3',
                title: 'Panjang Jarik & Lipatan Wiron',
                desc: 'Panjang standar kain jarik wiron keraton adalah 220 cm. Untuk lipatan wiron pria disarankan 7 atau 9 lipatan serong, sedangkan wiron wanita dibuat 5 atau 7 lipatan lurus yang anggun.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF382315),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Tutup Panduan', style: JText.serif(13.5, weight: FontWeight.w700, color: const Color(0xFFFFDF9E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection({required String number, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBCA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFF382315), shape: BoxShape.circle),
            child: Text(number, style: JText.serif(13, weight: FontWeight.w700, color: const Color(0xFFFFDF9E))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: JText.serif(14, weight: FontWeight.w700, color: const Color(0xFF382315))),
                const SizedBox(height: 4),
                Text(desc, style: JText.serif(12.5, color: const Color(0xFF5C4738), height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Modal Panduan Perawatan Wastra
  void _openWastraCareModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF6EE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDFCCB2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Perawatan Wastra & Batik Tulis', style: JText.serif(18, weight: FontWeight.w700, color: const Color(0xFF382315)), overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF7D6C5D)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCareItem(
              icon: Icons.local_laundry_service_outlined,
              title: 'Mencuci dengan Buah Lerak',
              desc: 'Gunakan cairan buah lerak alami atau sampo lembut. Hindari detergen keras yang dapat mengikis malam dan pewarna alami soga.',
            ),
            const SizedBox(height: 10),
            _buildCareItem(
              icon: Icons.wb_sunny_outlined,
              title: 'Jemur Angin-Angin di Tempat Teduh',
              desc: 'Jangan jemur kain batik langsung di bawah terik matahari. Cukup diangin-anginkan di tempat teduh agar serat sutra dan katun mori tetap awet.',
            ),
            const SizedBox(height: 10),
            _buildCareItem(
              icon: Icons.inventory_2_outlined,
              title: 'Simpan dengan Merica / Akar Wangi',
              desc: 'Hindari kapur barus langsung pada kain sutra dan beludru. Gunakan biji merica atau akar wangi kering untuk mencegah ngengat secara alami.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF382315),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Tutup Panduan', style: JText.serif(13.5, weight: FontWeight.w700, color: const Color(0xFFFFDF9E))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareItem({required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFB08D57), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: JText.serif(13.5, weight: FontWeight.w700, color: const Color(0xFF382315))),
                const SizedBox(height: 3),
                Text(desc, style: JText.serif(12, color: const Color(0xFF5C4738), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Modal Tentang JAVARA Busana Adat
  void _openAboutModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF6EE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0x44B08D57), width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDFCCB2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x22B08D57),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.checkroom_rounded, color: Color(0xFF382315), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JAVARA — Wastra & Busana Adat', style: JText.serif(17, weight: FontWeight.w800, color: const Color(0xFF382315))),
                      Text('Platform Busana Adat Jawa Tengah v1.2', style: JText.serif(12, color: const Color(0xFF7D6C5D))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'JAVARA adalah platform kurasi dan pelestarian busana tradisional Jawa Tengah: menghubungkan Anda langsung dengan pengrajin batik tulis, penjahit beskap keraton, sewa pakaian adat terpercaya, dan teknologi fitting virtual 3D.',
              style: JText.serif(13, color: const Color(0xFF5C4738), height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF382315),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Tutup', style: JText.serif(14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _isGuest
        ? 'T'
        : (_userName.isNotEmpty ? _userName.substring(0, 1).toUpperCase() : 'J');

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Pengguna',
                        style: JText.serif(
                          26,
                          weight: FontWeight.w800,
                          color: const Color(0xFF382315),
                        ),
                      ),
                      if (_showJavaneseScript)
                        const Text(
                          'ꦥꦿꦺꦴꦥ꦳ꦶꦭ꧀ꦥꦼꦔꦁꦒꦺꦴ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E7E50),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF382315), size: 24),
                  tooltip: 'Ubah Profil',
                  onPressed: () => _openEditProfileModal(context),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEADBCA)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C382315),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar Lingkaran dengan Inisial & Aksen Emas
                      Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF382315), Color(0xFF24150C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: const Color(0xFFDFB76C), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Color(0x18000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          initial,
                          style: JText.serif(
                            26,
                            weight: FontWeight.w800,
                            color: const Color(0xFFFFDF9E),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Nama & Identitas Pengguna
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: JText.serif(18, weight: FontWeight.w700, color: const Color(0xFF382315)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userEmail,
                              style: JText.serif(12, color: const Color(0xFF7D6C5D)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isGuest ? const Color(0x22DFB76C) : const Color(0x14B08D57),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isGuest ? const Color(0x66DFB76C) : const Color(0x38B08D57),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isGuest ? Icons.explore_rounded : Icons.checkroom_rounded,
                                    size: 12,
                                    color: _isGuest ? const Color(0xFF9E7E50) : const Color(0xFFB08D57),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isGuest
                                        ? 'Akun Tamu · Penjelajah Budaya'
                                        : 'Pelestari Wastra Jawa Tengah',
                                    style: JText.serif(10, weight: FontWeight.w700, color: const Color(0xFF382315)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFEADBCA), height: 1),
                  const SizedBox(height: 12),

                  // Dua Tombol Aksi: Ubah Profil & Alamat Pengiriman
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openEditProfileModal(context),
                          icon: const Icon(Icons.person_outline_rounded, size: 15, color: Color(0xFF382315)),
                          label: Text('Edit Profil', style: JText.serif(12, weight: FontWeight.w600, color: const Color(0xFF382315))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEADBCA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openEditProfileModal(context, isAddressOnly: true),
                          icon: const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFFB08D57)),
                          label: Text('Alamat Kirim', style: JText.serif(12, weight: FontWeight.w600, color: const Color(0xFF382315))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEADBCA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_isGuest) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2019), Color(0xFF1E1712)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDFB76C), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0x33DFB76C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Color(0xFFFFDF9E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Anda Menggunakan Akun Tamu',
                            style: JText.serif(
                              14,
                              weight: FontWeight.w700,
                              color: const Color(0xFFFFDF9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk atau daftar akun untuk menyimpan ukuran busana adat, riwayat fitting AI, dan pesanan secara permanen.',
                      style: JText.serif(
                        12,
                        color: const Color(0xFFEADBCA),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            fadeSlideRoute(const LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.login_rounded, size: 16, color: Color(0xFF1E1712)),
                        label: Text(
                          'Masuk atau Daftar Akun',
                          style: JText.sans(
                            13,
                            weight: FontWeight.w700,
                            color: const Color(0xFF1E1712),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDFB76C),
                          foregroundColor: const Color(0xFF1E1712),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            Text(
              'Aktivitas Busana Saya',
              style: JText.serif(17, weight: FontWeight.w700, color: const Color(0xFF382315)),
            ),

            const SizedBox(height: 10),

            Material(
              color: const Color(0xFFFFFDF9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFEADBCA)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildActivityListTile(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF382315),
                    title: 'Pesanan & Sewa Saya',
                    subtitle: '2 Busana Aktif (1 Disewa, 1 Dalam Kirim)',
                    badge: '2 Aktif',
                    badgeColor: const Color(0xFF4A6B48),
                    onTap: () => _openOrdersModal(context),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFEADBCA)),
                  _buildActivityListTile(
                    icon: Icons.bookmark_added_rounded,
                    iconColor: const Color(0xFFB08D57),
                    title: 'Wishlist & Koleksi Tersimpan',
                    subtitle: 'Koleksi setelan pusaka & kain batik pilihan',
                    badge: 'Lihat',
                    badgeColor: const Color(0xFFB08D57),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(fadeSlideRoute(const MyHeritageCollectionScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFEADBCA)),
                  _buildActivityListTile(
                    icon: Icons.checkroom_rounded,
                    iconColor: const Color(0xFFB5603A),
                    title: 'Riwayat Try-On & Padu Padan',
                    subtitle: 'Eksplorasi lemari 3D & fitting busana virtual',
                    badge: 'Buka',
                    badgeColor: const Color(0xFF5C4738),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (widget.onOpenTab != null) {
                        widget.onOpenTab!(2); // Pindah ke Tab Wardrobe
                      } else {
                        Navigator.of(context).push(fadeSlideRoute(const JavaneseWardrobeScreen()));
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ukuran Busana Saya (My Size)',
                    style: JText.serif(17, weight: FontWeight.w700, color: const Color(0xFF382315)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openSizeGuideModal(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.straighten_rounded, size: 14, color: Color(0xFFB08D57)),
                      const SizedBox(width: 4),
                      Text(
                        'Panduan',
                        style: JText.serif(12, weight: FontWeight.w600, color: const Color(0xFFB08D57)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEADBCA)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C382315), blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSizePill(
                          title: 'Baju / Kebaya',
                          value: _sizeTop,
                          icon: Icons.accessibility_new_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizePill(
                          title: 'Blangkon',
                          value: _sizeHead,
                          icon: Icons.face_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizePill(
                          title: 'Kain Jarik',
                          value: _sizeJarik,
                          icon: Icons.tune_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditSizeModal(context),
                      icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF382315)),
                      label: Text(
                        'Ubah Ukuran Busana Saya',
                        style: JText.serif(12.5, weight: FontWeight.w600, color: const Color(0xFF382315)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB08D57), width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Preferensi & Bantuan',
              style: JText.serif(17, weight: FontWeight.w700, color: const Color(0xFF382315)),
            ),

            const SizedBox(height: 10),

            Material(
              color: const Color(0xFFFFFDF9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFEADBCA)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Toggle Aksara Jawa
                  SwitchListTile(
                    value: _showJavaneseScript,
                    activeThumbColor: const Color(0xFFB08D57),
                    activeTrackColor: const Color(0x44B08D57),
                    title: Text(
                      'Tampilkan Aksara Jawa (ꦲꦤꦕꦫꦏ)',
                      style: JText.serif(13.5, weight: FontWeight.w600, color: const Color(0xFF382315)),
                    ),
                    subtitle: Text(
                      'Menampilkan aksara tradisional pada judul dan label busana',
                      style: JText.serif(11.5, color: const Color(0xFF7D6C5D)),
                    ),
                    onChanged: (v) {
                      setState(() => _showJavaneseScript = v);
                      _savePreference('javara_pref_aksara', v);
                      _showSnack(v ? 'Aksara Jawa diaktifkan.' : 'Aksara Jawa dinonaktifkan.');
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEADBCA)),
                  // Toggle Gamelan Lembut
                  SwitchListTile(
                    value: _ambientGamelan,
                    activeThumbColor: const Color(0xFFB08D57),
                    activeTrackColor: const Color(0x44B08D57),
                    title: Text(
                      'Musik Gamelan Pengiring Lembut',
                      style: JText.serif(13.5, weight: FontWeight.w600, color: const Color(0xFF382315)),
                    ),
                    subtitle: Text(
                      'Instrumen gamelan pelog & slendro relaksasi saat menjelajahi busana',
                      style: JText.serif(11.5, color: const Color(0xFF7D6C5D)),
                    ),
                    onChanged: (v) {
                      setState(() => _ambientGamelan = v);
                      _savePreference('javara_pref_gamelan', v);
                      _showSnack(v ? 'Gamelan pengiring diaktifkan.' : 'Gamelan pengiring dinonaktifkan.');
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEADBCA)),
                  // Panduan Perawatan Wastra
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.dry_cleaning_outlined, color: Color(0xFF382315), size: 22),
                      title: Text('Panduan Perawatan Wastra & Batik Tulis', style: JText.serif(13.5, weight: FontWeight.w600, color: const Color(0xFF382315))),
                      subtitle: Text('Cara mencuci dengan lerak & merawat kebaya beludru', style: JText.serif(11.5, color: const Color(0xFF7D6C5D))),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF7D6C5D)),
                      onTap: () => _openWastraCareModal(context),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEADBCA)),
                  // Tentang JAVARA Busana Adat
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF382315), size: 22),
                      title: Text('Tentang JAVARA Busana Adat', style: JText.serif(13.5, weight: FontWeight.w600, color: const Color(0xFF382315))),
                      subtitle: Text('Platform kurasi & pelestarian busana Jawa Tengah v1.2', style: JText.serif(11.5, color: const Color(0xFF7D6C5D))),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF7D6C5D)),
                      onTap: () => _openAboutModal(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB5603A), width: 1.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0x08B5603A),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFB5603A), size: 18),
                label: Text(
                  _isGuest ? 'Keluar dari Mode Tamu' : 'Keluar dari Akun',
                  style: JText.serif(13.5, weight: FontWeight.w700, color: const Color(0xFFB5603A)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'JAVARA · Khasanah Busana Adat Jawa Tengah © 2026',
                style: JText.serif(11.5, color: const Color(0xFF8C7B6D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: JText.serif(13.5, weight: FontWeight.w600, color: const Color(0xFF382315))),
        subtitle: Text(subtitle, style: JText.serif(11.5, color: const Color(0xFF7D6C5D))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: JText.serif(10, weight: FontWeight.w700, color: badgeColor),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF7D6C5D)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSizePill({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADBCA)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB08D57)),
          const SizedBox(height: 4),
          Text(
            title,
            style: JText.serif(10.5, color: const Color(0xFF7D6C5D), weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: JText.serif(11.5, weight: FontWeight.w700, color: const Color(0xFF382315)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
