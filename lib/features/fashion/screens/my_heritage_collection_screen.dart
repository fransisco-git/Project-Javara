import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'javanese_wardrobe_screen.dart';

/// Layar Koleksi Busana Tersimpan Pengguna ("Koleksi Pusaka Saya / My Heritage Collection")
class MyHeritageCollectionScreen extends StatefulWidget {
  const MyHeritageCollectionScreen({super.key});

  @override
  State<MyHeritageCollectionScreen> createState() => _MyHeritageCollectionScreenState();
}

class _MyHeritageCollectionScreenState extends State<MyHeritageCollectionScreen> {
  static const String _prefsKey = 'javara_saved_outfits_v1';
  List<SavedOutfit> _savedOutfits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedOutfits();
  }

  Future<void> _loadSavedOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];

    if (jsonList.isEmpty) {
      // Buat setelan contoh pusaka bawaan awal
      _savedOutfits = [
        SavedOutfit(
          id: 'default_saved_1',
          customName: 'Busana Ksatria Ageng Solo',
          savedDate: DateTime.now().subtract(const Duration(days: 2)),
          gender: GenderTarget.pria,
          headwearId: 'blangkon_surakarta_parang',
          upperBodyId: 'beskap_landhung_solo',
          lowerBodyId: 'jarik_batik_parang_barong_solo',
          accessoryIds: [
            'keris_ladrang_solo_kayu_timoho',
            'sabuk_cinde_epek_timang_emas',
            'selop_beludru_sulam_emas',
          ],
          isHistoricallyVerified: true,
          harmonyRating: 5,
          notes: 'Kombinasi resmi pasowanan agung Keraton Kasunanan Surakarta.',
        ),
        SavedOutfit(
          id: 'default_saved_2',
          customName: 'Keanggunan Putri Jepara',
          savedDate: DateTime.now().subtract(const Duration(days: 5)),
          gender: GenderTarget.wanita,
          headwearId: 'sanggul_tekuk_ronce_melati',
          upperBodyId: 'kebaya_kartini_beludru_jepara',
          lowerBodyId: 'jarik_batik_kawung_picis',
          accessoryIds: [
            'bros_rodha_kalung_ulur_putri',
            'selop_beludru_sulam_emas',
          ],
          isHistoricallyVerified: true,
          harmonyRating: 5,
          notes: 'Gaya kebaya panjang sutra bordir Kartinian dengan kain batik suci Kawung.',
        ),
      ];
      await _persistOutfits();
    } else {
      _savedOutfits = jsonList
          .map((s) => SavedOutfit.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _persistOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _savedOutfits.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  Future<void> _deleteOutfit(String id) async {
    setState(() {
      _savedOutfits.removeWhere((o) => o.id == id);
    });
    await _persistOutfits();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setelan dihapus dari koleksi.'),
          backgroundColor: Color(0xFF261A14),
        ),
      );
    }
  }

  void _showCompareDialog(SavedOutfit outfit1) {
    if (_savedOutfits.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simpan minimal 2 setelan busana untuk membandingkan.'),
          backgroundColor: Color(0xFF261A14),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1712),
          title: const Text(
            'Pilih Setelan Pembanding',
            style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _savedOutfits
                .where((o) => o.id != outfit1.id)
                .map(
                  (other) => ListTile(
                    title: Text(other.customName, style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 13)),
                    subtitle: Text(other.gender.label, style: const TextStyle(color: Color(0xFFA89989), fontSize: 11)),
                    trailing: const Icon(Icons.compare_arrows_rounded, color: Color(0xFFE4C590)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openSideBySideComparison(outfit1, other);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _openSideBySideComparison(SavedOutfit a, SavedOutfit b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final headA = JavaneseClothingData.getItemById(a.headwearId);
        final headB = JavaneseClothingData.getItemById(b.headwearId);
        final upperA = JavaneseClothingData.getItemById(a.upperBodyId);
        final upperB = JavaneseClothingData.getItemById(b.upperBodyId);
        final lowerA = JavaneseClothingData.getItemById(a.lowerBodyId);
        final lowerB = JavaneseClothingData.getItemById(b.lowerBodyId);

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF181310),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFE4C590), width: 1.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perbandingan Setelan Busana Adat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFAF6F0),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFFA89989)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Color(0x33E4C590)),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom A
                    Expanded(
                      child: _buildComparisonColumn(
                        title: a.customName,
                        gender: a.gender.label,
                        head: headA?.name ?? '-',
                        upper: upperA?.name ?? '-',
                        lower: lowerA?.name ?? '-',
                        notes: a.notes,
                        rating: a.harmonyRating,
                        color: const Color(0xFF261C14),
                      ),
                    ),
                    const VerticalDivider(color: Color(0x22E4C590), width: 16),
                    // Kolom B
                    Expanded(
                      child: _buildComparisonColumn(
                        title: b.customName,
                        gender: b.gender.label,
                        head: headB?.name ?? '-',
                        upper: upperB?.name ?? '-',
                        lower: lowerB?.name ?? '-',
                        notes: b.notes,
                        rating: b.harmonyRating,
                        color: const Color(0xFF221712),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonColumn({
    required String title,
    required String gender,
    required String head,
    required String upper,
    required String lower,
    required String notes,
    required int rating,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33E4C590)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFAF6F0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            gender,
            style: const TextStyle(fontSize: 10, color: Color(0xFFE4C590)),
          ),
          const SizedBox(height: 10),
          _compItem('Kepala', head),
          const SizedBox(height: 8),
          _compItem('Atasan', upper),
          const SizedBox(height: 8),
          _compItem('Bawahan', lower),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFFA89989), fontStyle: FontStyle.italic),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _compItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 8.5, color: Color(0xFFC79B3A), fontWeight: FontWeight.w800)),
        Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFFFAF6F0), fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE4C590), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Koleksi Pusaka Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
            ),
            Text(
              'ꦏꦺꦴꦭꦺꦏ꧀ꦱꦶꦥꦸꦱꦏꦏꦸ',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFE4C590).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE4C590)))
            : _savedOutfits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.checkroom_rounded, size: 56, color: Color(0x44E4C590)),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum Ada Busana Tersimpan',
                        style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Buka Studio Busana 3D dan simpan setelan kreasi Anda.',
                        style: TextStyle(color: Color(0xFFA89989), fontSize: 11),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4C590),
                          foregroundColor: const Color(0xFF14100D),
                        ),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const JavaneseWardrobeScreen()),
                        ),
                        child: const Text('Buka Studio 3D Sekarang'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _savedOutfits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _savedOutfits[index];
                    final head = JavaneseClothingData.getItemById(item.headwearId);
                    final upper = JavaneseClothingData.getItemById(item.upperBodyId);
                    final lower = JavaneseClothingData.getItemById(item.lowerBodyId);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1712),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x44E4C590), width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.customName,
                                      style: JText.serif(
                                        15,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFFAF6F0),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.gender.label} · Disimpan ${item.savedDate.day}/${item.savedDate.month}/${item.savedDate.year}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFFA89989)),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.compare_arrows_rounded, color: Color(0xFFE4C590), size: 20),
                                    tooltip: 'Bandingkan',
                                    onPressed: () => _showCompareDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB85959), size: 20),
                                    tooltip: 'Hapus',
                                    onPressed: () => _deleteOutfit(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(color: Color(0x1AE4C590), height: 16),
                          Text('Kepala: ${head?.name ?? "-"}', style: const TextStyle(fontSize: 11, color: Color(0xFFD4C8BC))),
                          Text('Atasan: ${upper?.name ?? "-"}', style: const TextStyle(fontSize: 11, color: Color(0xFFD4C8BC))),
                          Text('Bawahan: ${lower?.name ?? "-"}', style: const TextStyle(fontSize: 11, color: Color(0xFFD4C8BC))),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE4C590),
                                side: const BorderSide(color: Color(0xFFE4C590)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => JavaneseWardrobeScreen(savedOutfitToLoad: item),
                                  ),
                                );
                              },
                              child: const Text('Kenakan Kembali di Studio 3D'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
