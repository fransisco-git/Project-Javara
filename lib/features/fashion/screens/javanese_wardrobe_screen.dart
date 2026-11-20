import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import '../models/realistic_fashion_model.dart';
import '../widgets/javanese_garment_detail_sheet.dart';
import '../widgets/realistic_fashion_model_stage.dart';
import '../widgets/settigation_clothes_closet.dart';
import '../widgets/threejs_wardrobe_webview.dart';
import 'ai_fashion_studio_screen.dart';
import 'ai_cultural_assistant_screen.dart';
import 'jelajahi_busana_screen.dart';
import 'my_heritage_collection_screen.dart';
import 'sinau_busana_screen.dart';

/// Mode Tampilan Wardrobe Interaktif JAVARA
enum WardrobeViewMode {
  modelStage, // Model Peraga Busana Adat Realistis 3D
  settigationRail, // Lemari Rel Gantungan Settigation Tech Closet
  integratedStudio, // Studio Terpadu (Runway Model + Rel Settigation)
  threeJsPbrStudio, // Real-Time Three.js WebGL Studio PBR
}

/// Studio Wardrobe Interaktif Busana Adat Jawa Tengah
/// Menggabungkan konsep Settigation Clothes Closet (horizontal rail, hanger kayu, kartu tag)
/// dan Panggung Peraga Busana Adat Realistis dengan Model Manusia Autentik & 3D Turntable.
class JavaneseWardrobeScreen extends StatefulWidget {
  const JavaneseWardrobeScreen({
    super.key,
    this.initialOutfit,
    this.savedOutfitToLoad,
  });

  final TraditionalOutfit? initialOutfit;
  final SavedOutfit? savedOutfitToLoad;

  @override
  State<JavaneseWardrobeScreen> createState() => _JavaneseWardrobeScreenState();
}

class _JavaneseWardrobeScreenState extends State<JavaneseWardrobeScreen>
    with TickerProviderStateMixin {
  WardrobeViewMode _currentMode = WardrobeViewMode.integratedStudio;
  GenderTarget _currentGender = GenderTarget.pria;

  // Model Peraga Busana Realistis yang Sedang Ditampilkan
  late RealisticFashionModel _activeRealisticModel;

  // Garment Terpasang pada Karakter/Model
  ClothingItem? _activeHeadwear;
  ClothingItem? _activeUpperBody;
  ClothingItem? _activeLowerBody;
  final List<ClothingItem> _activeAccessories = [];

  // Animasi Terbang Pemasangan Baju (Equip Transition)
  late final AnimationController _equipAnimController;
  ClothingItem? _recentlyEquippedGarment;

  @override
  void initState() {
    super.initState();

    _activeRealisticModel = RealisticFashionModel.curatedModels.first;

    _equipAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.initialOutfit != null) {
      _applyCuratedOutfit(widget.initialOutfit!);
    } else if (widget.savedOutfitToLoad != null) {
      _applySavedOutfit(widget.savedOutfitToLoad!);
    } else {
      _applyDefaultOutfit(GenderTarget.pria);
    }
  }

  @override
  void dispose() {
    _equipAnimController.dispose();
    super.dispose();
  }

  void _applyDefaultOutfit(GenderTarget gender) {
    _currentGender = gender;
    if (gender == GenderTarget.pria) {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_jawi_jangkep_solo');
      _activeHeadwear = JavaneseClothingData.getItemById('blangkon_surakarta_parang');
      _activeUpperBody = JavaneseClothingData.getItemById('beskap_landhung_solo');
      _activeLowerBody = JavaneseClothingData.getItemById('jarik_batik_parang_barong_solo');
      _activeAccessories.clear();
      final keris = JavaneseClothingData.getItemById('keris_ladrang_solo_kayu_timoho');
      final sabuk = JavaneseClothingData.getItemById('sabuk_cinde_epek_timang_emas');
      if (keris != null) _activeAccessories.add(keris);
      if (sabuk != null) _activeAccessories.add(sabuk);
    } else {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_kebaya_kartini_solo');
      _activeHeadwear = JavaneseClothingData.getItemById('sanggul_tekuk_ronce_melati');
      _activeUpperBody = JavaneseClothingData.getItemById('kebaya_kartini_beludru_jepara');
      _activeLowerBody = JavaneseClothingData.getItemById('jarik_batik_truntum_solo');
      _activeAccessories.clear();
      final bros = JavaneseClothingData.getItemById('bros_rodha_kalung_ulur_putri');
      if (bros != null) _activeAccessories.add(bros);
    }
  }

  void _applyCuratedOutfit(TraditionalOutfit outfit) {
    setState(() {
      _currentGender = outfit.gender;
      _activeHeadwear = JavaneseClothingData.getItemById(outfit.headwearId);
      _activeUpperBody = JavaneseClothingData.getItemById(outfit.upperBodyId);
      _activeLowerBody = JavaneseClothingData.getItemById(outfit.lowerBodyId);
      _activeAccessories.clear();
      for (final accId in outfit.accessoryIds) {
        final acc = JavaneseClothingData.getItemById(accId);
        if (acc != null) _activeAccessories.add(acc);
      }
      _syncRealisticModelToOutfit(outfit.upperBodyId);
    });
  }

  void _applySavedOutfit(SavedOutfit saved) {
    setState(() {
      _currentGender = saved.gender;
      _activeHeadwear = JavaneseClothingData.getItemById(saved.headwearId);
      _activeUpperBody = JavaneseClothingData.getItemById(saved.upperBodyId);
      _activeLowerBody = JavaneseClothingData.getItemById(saved.lowerBodyId);
      _activeAccessories.clear();
      for (final accId in saved.accessoryIds) {
        final acc = JavaneseClothingData.getItemById(accId);
        if (acc != null) _activeAccessories.add(acc);
      }
      _syncRealisticModelToOutfit(saved.upperBodyId);
    });
  }

  void _syncRealisticModelToOutfit(String upperBodyId) {
    final lowerId = upperBodyId.toLowerCase();
    if (lowerId.contains('surjan') || lowerId.contains('lurik')) {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_surjan_pranakan_solo');
      _currentGender = GenderTarget.pria;
    } else if (lowerId.contains('basahan') || lowerId.contains('dodot') || lowerId.contains('kampuh')) {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_solo_basahan_bride');
      _currentGender = GenderTarget.wanita;
    } else if (lowerId.contains('kebaya') || lowerId.contains('kartini')) {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_kebaya_kartini_solo');
      _currentGender = GenderTarget.wanita;
    } else {
      _activeRealisticModel = RealisticFashionModel.getModelById('model_jawi_jangkep_solo');
      _currentGender = GenderTarget.pria;
    }
  }

  void _onModelSelected(RealisticFashionModel model) {
    setState(() {
      _activeRealisticModel = model;
      _currentGender = model.gender;

      // Update busana yang terpasang sesuai karakteristik model terpilih
      switch (model.id) {
        case 'model_jawi_jangkep_solo':
          _activeUpperBody = JavaneseClothingData.getItemById('beskap_landhung_solo');
          _activeHeadwear = JavaneseClothingData.getItemById('blangkon_surakarta_parang');
          _activeLowerBody = JavaneseClothingData.getItemById('jarik_batik_parang_barong_solo');
          break;
        case 'model_kebaya_kartini_solo':
          _activeUpperBody = JavaneseClothingData.getItemById('kebaya_kartini_beludru_jepara');
          _activeHeadwear = JavaneseClothingData.getItemById('sanggul_tekuk_ronce_melati');
          _activeLowerBody = JavaneseClothingData.getItemById('jarik_batik_truntum_solo');
          break;
        case 'model_solo_basahan_bride':
          _activeUpperBody = JavaneseClothingData.getItemById('dodot_kampuh_alas_alasan');
          _activeHeadwear = JavaneseClothingData.getItemById('paes_solo_basahan_hijau');
          _activeLowerBody = JavaneseClothingData.getItemById('jarik_cinde_samparan_prada');
          break;
        case 'model_surjan_pranakan_solo':
          _activeUpperBody = JavaneseClothingData.getItemById('surjan_pranakan_lurik_klasik');
          _activeHeadwear = JavaneseClothingData.getItemById('blangkon_surakarta_sogan');
          _activeLowerBody = JavaneseClothingData.getItemById('jarik_batik_parang_kusumo_solo');
          break;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1712),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDFB76C), width: 1.0),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFDFB76C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Model Peraga ${model.title} siap dipelajari.',
                style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _equipGarmentFromSettigation(ClothingItem item) {
    setState(() {
      _recentlyEquippedGarment = item;
      switch (item.category) {
        case ClothingCategory.headwear:
          _activeHeadwear = item;
          break;
        case ClothingCategory.upperBody:
          _activeUpperBody = item;
          _syncRealisticModelToOutfit(item.id);
          break;
        case ClothingCategory.lowerBody:
          _activeLowerBody = item;
          break;
        case ClothingCategory.accessories:
          if (!_activeAccessories.any((a) => a.id == item.id)) {
            _activeAccessories.add(item);
          }
          break;
      }
    });

    _equipAnimController.forward(from: 0.0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1712),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDFB76C), width: 1.0),
        ),
        content: Row(
          children: [
            const Icon(Icons.checkroom_rounded, color: Color(0xFFDFB76C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.name} berhasil dipakaikan ke Model Peraga ${_activeRealisticModel.title}.',
                style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({bool isAuthentic, String title, String explanation}) _checkAuthenticity() {
    if (_activeUpperBody == null || _activeLowerBody == null || _activeHeadwear == null) {
      return (
        isAuthentic: false,
        title: 'Setelan Belum Lengkap',
        explanation: 'Lengkapi penutup kepala, busana atasan, dan kain jarik bawahan.',
      );
    }

    final isSameRegion = _activeUpperBody!.region == _activeLowerBody!.region &&
        _activeHeadwear!.region == _activeUpperBody!.region;

    final isUpperLowerCompatible = _activeUpperBody!.isCompatibleWith(_activeLowerBody!);
    final isHeadUpperCompatible = _activeHeadwear!.isCompatibleWith(_activeUpperBody!);

    if (isUpperLowerCompatible && isHeadUpperCompatible && isSameRegion) {
      return (
        isAuthentic: true,
        title: 'Kombinasi Adiluhung Klasik ${_activeUpperBody!.region.title}',
        explanation:
            'Seluruh elemen busana selaras menurut paugeran tata busana keraton/daerah ${_activeUpperBody!.region.title}.',
      );
    } else if (isUpperLowerCompatible || isHeadUpperCompatible) {
      return (
        isAuthentic: true,
        title: 'Kombinasi Adat Luwes Antar-Wilayah',
        explanation:
            'Perpaduan busana masih dalam koridor tata kesantunan tradisi Jawa Tengah yang lazim dalam resepsi adat.',
      );
    } else {
      return (
        isAuthentic: false,
        title: 'Kreasi Kontemporer Terbuka',
        explanation:
            'Kombinasi eksperimental lintas wilayah atau periode sejarah. Tidak dianggap sebagai setelan adat pakem murni.',
      );
    }
  }

  Future<void> _saveCurrentOutfitDialog() async {
    final nameController = TextEditingController(
      text: 'Setelan ${_activeUpperBody?.name ?? _activeRealisticModel.title}',
    );
    final auth = _checkAuthenticity();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1712),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0x66DFB76C)),
          ),
          title: Row(
            children: [
              const Icon(Icons.bookmark_add_rounded, color: Color(0xFFDFB76C), size: 22),
              const SizedBox(width: 8),
              Text(
                'Simpan ke Koleksi Saya',
                style: JText.serif(16, weight: FontWeight.w700, color: const Color(0xFFFAF6F0)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beri nama untuk setelan busana model ini:',
                style: TextStyle(color: Color(0xFFA89989), fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF14100D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0x44DFB76C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDFB76C)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16120E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      auth.isAuthentic ? Icons.verified_rounded : Icons.palette_rounded,
                      color: const Color(0xFFDFB76C),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.title,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFDFB76C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal', style: TextStyle(color: Color(0xFFA89989))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDFB76C),
                foregroundColor: const Color(0xFF14100D),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final newSaved = SavedOutfit(
        id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
        customName: nameController.text.trim().isEmpty ? 'Setelan Busana Jawa' : nameController.text.trim(),
        savedDate: DateTime.now(),
        gender: _currentGender,
        headwearId: _activeHeadwear?.id ?? '',
        upperBodyId: _activeUpperBody?.id ?? '',
        lowerBodyId: _activeLowerBody?.id ?? '',
        accessoryIds: _activeAccessories.map((a) => a.id).toList(),
        isHistoricallyVerified: auth.isAuthentic,
        harmonyRating: auth.isAuthentic ? 5 : 4,
        notes: auth.explanation,
      );

      final prefs = await SharedPreferences.getInstance();
      final currentList = prefs.getStringList('javara_saved_outfits_v1') ?? [];
      currentList.insert(0, jsonEncode(newSaved.toJson()));
      await prefs.setStringList('javara_saved_outfits_v1', currentList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Setelan busana berhasil disimpan ke Koleksi Pusaka Saya.'),
            backgroundColor: Color(0xFF261A14),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = _checkAuthenticity();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: Stack(
          children: [
          // -------------------------------------------------------------------
          // 1. KONTEN UTAMA BERDASARKAN MODE TAMPILAN
          // -------------------------------------------------------------------
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 105),
                child: _buildMainContentByMode(),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // 2. HEADER BAR: NAVIGASI, JUDUL, & PENGALIH MODE TAMPILAN
          // -------------------------------------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildMasterHeader(auth),
          ),

          // -------------------------------------------------------------------
          // 3. BAR TOMBOL HUBUNG FITUR & KOLEKSI (JELAJAHI, SINAU, KOLEKSI)
          // -------------------------------------------------------------------
          if (_currentMode != WardrobeViewMode.settigationRail)
            Positioned(
              left: 16,
              right: 16,
              top: 112,
              child: _buildHeritageQuickLinks(),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildMainContentByMode() {
    switch (_currentMode) {
      case WardrobeViewMode.threeJsPbrStudio:
        // Studio Real-Time 3D WebGL PBR Tiga Dimensi
        return ThreeJsWardrobeWebView(
          currentModel: _activeRealisticModel,
          onSelectModel: _onModelSelected,
        );

      case WardrobeViewMode.modelStage:
        // Panggung Peraga Busana Adat Realistis Penuh
        return RealisticFashionModelStage(
          currentModel: _activeRealisticModel,
          onSelectModel: _onModelSelected,
          isEmbeddedMode: false,
        );

      case WardrobeViewMode.settigationRail:
        // Lemari Rel Gantungan Settigation Penuh (Horisontal Rail & Hanger)
        return SettigationClothesCloset(
          selectedGender: _currentGender,
          activeGarmentId: _activeUpperBody?.id,
          onEquipToModel: _equipGarmentFromSettigation,
          onInspectGarment: (item) {
            JavaneseGarmentDetailSheet.show(context, item);
          },
          isCompactMode: false,
        );

      case WardrobeViewMode.integratedStudio:
        // Studio Terpadu: Atas Model Peraga Realistis, Bawah Rel Gantungan Settigation
        return Column(
          children: [
            // Panggung Model Realistis (Atas)
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  RealisticFashionModelStage(
                    currentModel: _activeRealisticModel,
                    onSelectModel: _onModelSelected,
                    isEmbeddedMode: true,
                  ),

                  // Animasi Umpan Balik Baju Dipakaikan
                  if (_recentlyEquippedGarment != null && _equipAnimController.isAnimating)
                    Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.15).animate(
                          CurvedAnimation(parent: _equipAnimController, curve: Curves.easeOutBack),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xEE1E1712),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDFB76C), width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x88000000), blurRadius: 12),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.checkroom_rounded, color: Color(0xFFDFB76C), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Memakaikan ${_recentlyEquippedGarment!.name}...',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFAF6F0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Rel Gantungan Busana Settigation (Bawah)
            Expanded(
              flex: 10,
              child: SettigationClothesCloset(
                selectedGender: _currentGender,
                activeGarmentId: _activeUpperBody?.id,
                onEquipToModel: _equipGarmentFromSettigation,
                onInspectGarment: (item) {
                  JavaneseGarmentDetailSheet.show(context, item);
                },
                isCompactMode: true,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildMasterHeader(({bool isAuthentic, String title, String explanation}) auth) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF214100D),
        border: Border(bottom: BorderSide(color: Color(0x33DFB76C), width: 0.8)),
        boxShadow: [
          BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Baris 1: Tombol Balik, Judul, & Tombol Simpan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xBB1E1712),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(7),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFDFB76C), size: 15),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Judul & Aksara Jawa
                  Column(
                    children: [
                      const Text(
                        'Museum Busana Adat JAVARA',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFAF6F0),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'ꦩꦸꦱꦶꦪꦸꦩ꧀ꦧꦸꦱꦤꦗꦮ • Jawa Tengah',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: const Color(0xFFDFB76C).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),

                  // Tombol Simpan Setelan ke Koleksi
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xBB1E1712),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(7),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.bookmark_add_outlined, color: Color(0xFFDFB76C), size: 17),
                      tooltip: 'Simpan ke Koleksi Saya',
                      onPressed: _saveCurrentOutfitDialog,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Baris 2: Pengalih Mode (Studio Terpadu / 3D WebGL / Model Peraga / Rel Settigation)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1712),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
                ),
                child: Row(
                  children: [
                    _buildModeTab(
                      mode: WardrobeViewMode.integratedStudio,
                      label: 'Terpadu',
                      icon: Icons.splitscreen_rounded,
                    ),
                    _buildModeTab(
                      mode: WardrobeViewMode.threeJsPbrStudio,
                      label: '3D WebGL',
                      icon: Icons.view_in_ar_rounded,
                    ),
                    _buildModeTab(
                      mode: WardrobeViewMode.modelStage,
                      label: 'Model Peraga',
                      icon: Icons.accessibility_new_rounded,
                    ),
                    _buildModeTab(
                      mode: WardrobeViewMode.settigationRail,
                      label: 'Rel Gantungan',
                      icon: Icons.shelves,
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

  Widget _buildModeTab({
    required WardrobeViewMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentMode = mode),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFDFB76C) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF14100D) : const Color(0xFFA89989),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF14100D) : const Color(0xFFA89989),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeritageQuickLinks() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildQuickPill(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Studio Try-On',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiFashionStudioScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickPill(
            icon: Icons.psychology_rounded,
            label: 'AI Pakar Busana',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiCulturalAssistantScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickPill(
            icon: Icons.style_rounded,
            label: 'Jelajahi Set Kurasi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JelajahiBusanaScreen(
                    onSelectOutfit: _applyCuratedOutfit,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickPill(
            icon: Icons.menu_book_rounded,
            label: 'Sinau Busana Adat',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SinauBusanaScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickPill(
            icon: Icons.collections_bookmark_rounded,
            label: 'Koleksi Saya',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyHeritageCollectionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xDD1E1712),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x55DFB76C), width: 0.8),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFFDFB76C)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
