import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../services/saved_garments_service.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'cermin_busana_screen.dart';

/// Layar Utama Tab Wardrobe JAVARA — Unified Personal Styling & Saved Wardrobe.
///
/// Mengintegrasikan:
/// 1. Top Styling Canvas / Stage (Anywear-inspired):
///    Kanvas netral hangat (#F4F2EE) untuk memadukan layer busana Jawa Tengah
///    (Atasan, Bawahan, Pelengkap), kontrol ganti/reset, dan simpan setelan.
/// 2. Segmented Switcher:
///    - `Kanvas Gaya`: Tray pemilih layer busana untuk langsung diterapkan ke kanvas.
///    - `Item Tersimpan`: Daftar busana yang dibookmark dari tab Koleksi.
///    - `Setelan Saya`: Koleksi setelan busana yang telah disimpan pengguna.
class WardrobeTab extends StatefulWidget {
  const WardrobeTab({
    super.key,
    this.onOpenCatalog,
  });

  final VoidCallback? onOpenCatalog;

  @override
  State<WardrobeTab> createState() => _WardrobeTabState();
}

class _WardrobeTabState extends State<WardrobeTab> {
  // Layer Aktif di Styling Canvas
  ClothingItem? _activeUpperBody;
  ClothingItem? _activeLowerBody;
  ClothingItem? _activeAccessory;

  GenderTarget _activeGender = GenderTarget.pria;
  int _segmentIndex = 0; // 0: Kanvas Gaya, 1: Item Tersimpan, 2: Setelan Saya
  ClothingCategory _canvasCategoryTray = ClothingCategory.upperBody;

  @override
  void initState() {
    super.initState();
    _applyDefaultCanvasOutfit(GenderTarget.pria);
    SavedGarmentsService.instance.initialize();
  }

  void _applyDefaultCanvasOutfit(GenderTarget gender) {
    _activeGender = gender;
    if (gender == GenderTarget.pria) {
      _activeUpperBody =
          JavaneseClothingData.getItemById('beskap_landhung_solo');
      _activeLowerBody =
          JavaneseClothingData.getItemById('jarik_batik_parang_barong_solo');
      _activeAccessory =
          JavaneseClothingData.getItemById('blangkon_surakarta_parang');
    } else {
      _activeUpperBody =
          JavaneseClothingData.getItemById('kebaya_kutubaru_beludru_solo');
      _activeLowerBody =
          JavaneseClothingData.getItemById('jarik_batik_buketan_pekalongan');
      _activeAccessory =
          JavaneseClothingData.getItemById('selendang_batik_truntum_solo') ??
              JavaneseClothingData.accessoryItems.first;
    }
  }

  void _equipGarment(ClothingItem item) {
    HapticFeedback.selectionClick();
    setState(() {
      if (item.category == ClothingCategory.upperBody) {
        _activeUpperBody = (_activeUpperBody?.id == item.id) ? null : item;
      } else if (item.category == ClothingCategory.lowerBody) {
        _activeLowerBody = (_activeLowerBody?.id == item.id) ? null : item;
      } else {
        _activeAccessory = (_activeAccessory?.id == item.id) ? null : item;
      }
    });
  }

  void _resetCanvas() {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeUpperBody = null;
      _activeLowerBody = null;
      _activeAccessory = null;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1200),
        backgroundColor: Color(0xFF241A14),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Kanvas gaya telah dibersihkan',
          style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
        ),
      ),
    );
  }

  void _showSaveOutfitDialog() {
    if (_activeUpperBody == null &&
        _activeLowerBody == null &&
        _activeAccessory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu busana pada kanvas sebelum menyimpan setelan'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final defaultTitle =
        'Setelan ${_activeUpperBody?.name ?? 'Adat'} ${now.day}/${now.month}';
    final textController = TextEditingController(text: defaultTitle);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1612),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simpan Setelan Anda',
                    style: JText.editorial(
                      18,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFFB0A290)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Nama Setelan',
                style: JText.sans(
                  12,
                  weight: FontWeight.w500,
                  color: const Color(0xFFD4C8B8),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF261D17),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0x44DFB76C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDFB76C)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = textController.text.trim().isEmpty
                        ? defaultTitle
                        : textController.text.trim();
                    Navigator.pop(ctx);

                    final outfit = SavedOutfit(
                      id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
                      customName: title,
                      savedDate: DateTime.now(),
                      gender: _activeGender,
                      headwearId: _activeAccessory?.id ?? '',
                      upperBodyId: _activeUpperBody?.id ?? '',
                      lowerBodyId: _activeLowerBody?.id ?? '',
                      accessoryIds: [],
                      isHistoricallyVerified: true,
                      harmonyRating: 5,
                      notes: 'Kreasi Kanvas Gaya JAVARA',
                    );

                    await SavedGarmentsService.instance.saveOutfit(outfit);
                    if (!mounted) return;
                    setState(() => _segmentIndex = 2); // Buka tab Setelan Saya
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF241A14),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          '"$title" berhasil disimpan ke Setelan Saya',
                          style: const TextStyle(
                            color: Color(0xFFFAF6F0),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JColors.antiqueGold,
                    foregroundColor: const Color(0xFF14100D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Simpan ke Setelan Saya',
                    style: JText.sans(
                      14,
                      weight: FontWeight.w700,
                      color: const Color(0xFF14100D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applySavedOutfitToCanvas(SavedOutfit outfit) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeGender = outfit.gender;
      _activeUpperBody =
          outfit.upperBodyId.isNotEmpty
              ? JavaneseClothingData.getItemById(outfit.upperBodyId)
              : null;
      _activeLowerBody =
          outfit.lowerBodyId.isNotEmpty
              ? JavaneseClothingData.getItemById(outfit.lowerBodyId)
              : null;
      _activeAccessory =
          outfit.headwearId.isNotEmpty
              ? JavaneseClothingData.getItemById(outfit.headwearId)
              : null;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1400),
        backgroundColor: const Color(0xFF241A14),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Setelan "${outfit.customName}" diterapkan ke Kanvas Gaya',
          style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
        ),
      ),
    );
  }

  // --- BUILD UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. TOP BAR & EDITORIAL HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261D17),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0x33DFB76C),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.checkroom_rounded,
                        color: JColors.antiqueGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wardrobe Pribadi',
                            style: JText.editorial(
                              20,
                              weight: FontWeight.w700,
                              color: const Color(0xFFFAF6F0),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paduan Busana Adat & Koleksi Tersimpan',
                            style: JText.sans(
                              11.5,
                              weight: FontWeight.w400,
                              color: const Color(0xFFB0A290),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Shortcut ke Cermin Busana (Kamera Live)
                    IconButton(
                      tooltip: 'Cermin Busana (Kamera Live)',
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: JColors.antiqueGold,
                        size: 22,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CerminBusanaScreen(
                              initialState: CerminState.liveCamera,
                              enableCameraAutoStart: true,
                              onSwitchToCatalogTab: widget.onOpenCatalog,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 2. TOP STYLING CANVAS / STAGE (ANYWEAR-INSPIRED)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTopStylingCanvas(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. SEGMENTED SWITCHER (Kanvas Gaya | Item Tersimpan | Setelan Saya)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSegmentedSwitcher(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 4. SEGMENT CONTENT BODY
            _buildActiveSegmentView(),

            // Bottom Inset Padding (Clear bottom navigation bar)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 84,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN KANVAS GAYA ATAS (ANYWEAR STYLE) ---

  Widget _buildTopStylingCanvas() {
    // Menghitung konteks budaya & acara secara halus
    final regionTitle = _activeUpperBody?.region.title ??
        _activeLowerBody?.region.title ??
        'Surakarta Hadiningrat';
    final contextLabel = _activeUpperBody?.socialContext.label ??
        _activeLowerBody?.socialContext.label ??
        'Upacara Agung & Resmi';

    final equippedCount = (_activeAccessory != null ? 1 : 0) +
        (_activeUpperBody != null ? 1 : 0) +
        (_activeLowerBody != null ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EE), // Neutral warm backdrop retail clarity
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2DCD2),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A. Context Tag & Action Controls Top Row
          Row(
            children: [
              // Subtle Context Tag (No loud overlays)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E2D8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD6CABA),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: Color(0xFF7A654C),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$regionTitle • $contextLabel',
                          style: JText.serif(
                            11,
                            weight: FontWeight.w600,
                            color: const Color(0xFF4A3828),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Swap Gender (Pria / Wanita)
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _applyDefaultCanvasOutfit(
                    _activeGender == GenderTarget.pria
                        ? GenderTarget.wanita
                        : GenderTarget.pria,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E2D8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD6CABA),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _activeGender == GenderTarget.pria ? 'Pria' : 'Wanita',
                    style: JText.sans(
                      11,
                      weight: FontWeight.w700,
                      color: const Color(0xFF382A1D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Clear/Reset Canvas Button
              IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF7A654C),
                ),
                tooltip: 'Atur Ulang Kanvas',
                onPressed: _resetCanvas,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // B. Center Layer Visualizer (Mannequin Canvas + Slot Chips)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Garment Layer Stack Display
              Expanded(
                flex: 11,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(160),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE5DFD6),
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Layer 1: Pelengkap / Blangkon / Aksesoris
                      _buildCanvasLayerSlot(
                        item: _activeAccessory,
                        slotLabel: 'Pelengkap',
                        fallbackIcon: Icons.military_tech_outlined,
                        height: 38,
                        onTap: () {
                          setState(() {
                            _canvasCategoryTray = ClothingCategory.headwear;
                            _segmentIndex = 0;
                          });
                        },
                      ),
                      // Layer 2: Atasan (Beskap / Kebaya / Surjan)
                      _buildCanvasLayerSlot(
                        item: _activeUpperBody,
                        slotLabel: 'Atasan',
                        fallbackIcon: Icons.checkroom_outlined,
                        height: 72,
                        onTap: () {
                          setState(() {
                            _canvasCategoryTray = ClothingCategory.upperBody;
                            _segmentIndex = 0;
                          });
                        },
                      ),
                      // Layer 3: Bawahan (Jarik Batik / Celana)
                      _buildCanvasLayerSlot(
                        item: _activeLowerBody,
                        slotLabel: 'Bawahan',
                        fallbackIcon: Icons.layers_outlined,
                        height: 64,
                        onTap: () {
                          setState(() {
                            _canvasCategoryTray = ClothingCategory.lowerBody;
                            _segmentIndex = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Slot Quick Chips di Sisi Kanan
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSlotSelectorPill(
                      title: 'Pelengkap',
                      item: _activeAccessory,
                      category: ClothingCategory.headwear,
                    ),
                    const SizedBox(height: 6),
                    _buildSlotSelectorPill(
                      title: 'Atasan',
                      item: _activeUpperBody,
                      category: ClothingCategory.upperBody,
                    ),
                    const SizedBox(height: 6),
                    _buildSlotSelectorPill(
                      title: 'Bawahan',
                      item: _activeLowerBody,
                      category: ClothingCategory.lowerBody,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // C. Bottom Row: Layer Summary + "Simpan Setelan" CTA
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  equippedCount == 0
                      ? 'Kanvas kosong'
                      : '$equippedCount Lapis Busana',
                  style: JText.sans(
                    11.5,
                    weight: FontWeight.w600,
                    color: const Color(0xFF6A5745),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Button "Simpan Setelan"
              Expanded(
                flex: 6,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: _showSaveOutfitDialog,
                      icon: const Icon(
                        Icons.bookmark_add_outlined,
                        size: 16,
                        color: Color(0xFF14100D),
                      ),
                      label: Text(
                        'Simpan Setelan',
                        style: JText.sans(
                          12,
                          weight: FontWeight.w700,
                          color: const Color(0xFF14100D),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JColors.antiqueGold,
                        foregroundColor: const Color(0xFF14100D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasLayerSlot({
    required ClothingItem? item,
    required String slotLabel,
    required IconData fallbackIcon,
    required double height,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: item != null
              ? const Color(0xFFFAF8F5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: item != null
                ? const Color(0xFFDFB76C)
                : const Color(0xFFD4CBBB),
            width: item != null ? 1.0 : 0.8,
            style: item != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: item != null
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/garments/${item.id}.png',
                      width: height - 6,
                      height: height - 6,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Image.asset(
                        item.imageAsset,
                        width: height - 6,
                        height: height - 6,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: JText.serif(
                              11.5,
                              weight: FontWeight.w700,
                              color: const Color(0xFF2C2219),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.region.title,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF7A654C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFB08D57),
                    size: 16,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(fallbackIcon, size: 15, color: const Color(0xFF9E8F7F)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '+ $slotLabel',
                        style: JText.sans(
                          11,
                          weight: FontWeight.w500,
                          color: const Color(0xFF9E8F7F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSlotSelectorPill({
    required String title,
    required ClothingItem? item,
    required ClothingCategory category,
  }) {
    final isSelectedTray = _canvasCategoryTray == category;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _canvasCategoryTray = category;
          _segmentIndex = 0; // Alihkan ke baki Kanvas Gaya
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isSelectedTray
              ? const Color(0xFF2E2219)
              : const Color(0xFFE8E2D8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelectedTray
                ? JColors.antiqueGold
                : const Color(0xFFD6CABA),
            width: isSelectedTray ? 1.0 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: JText.sans(
                10,
                weight: FontWeight.w700,
                color: isSelectedTray
                    ? JColors.antiqueGold
                    : const Color(0xFF6B5845),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item?.name ?? 'Ketuk untuk memilih',
              style: JText.serif(
                11,
                weight: FontWeight.w600,
                color: isSelectedTray
                    ? const Color(0xFFFAF6F0)
                    : const Color(0xFF2C2219),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- SEGMENTED SWITCHER (ANTI-SLOP, DOCKED FLAT) ---

  Widget _buildSegmentedSwitcher() {
    final labels = ['Kanvas Gaya', 'Item Tersimpan', 'Setelan Saya'];

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1612),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0x33DFB76C),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = _segmentIndex == i;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: labels[i],
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _segmentIndex = i);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E2219)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: JColors.antiqueGold, width: 0.8)
                        : null,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        style: JText.sans(
                          12,
                          weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFFFDF9E)
                              : const Color(0xFF8F8073),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- CONTENT PER SEGMENT ---

  Widget _buildActiveSegmentView() {
    switch (_segmentIndex) {
      case 0:
        return _buildKanvasGayaTray();
      case 1:
        return _buildItemTersimpanView();
      case 2:
        return _buildSetelanSayaView();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  // 1. SEGMENT 0: KANVAS GAYA TRAY
  Widget _buildKanvasGayaTray() {
    final items = JavaneseClothingData.clothingItems
        .where((item) =>
            item.category == _canvasCategoryTray &&
            (item.gender == _activeGender || item.gender == GenderTarget.unisex))
        .toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Kategori Pills (Atasan, Bawahan, Pelengkap)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCategoryFilterChip(
                    label: 'Atasan',
                    category: ClothingCategory.upperBody,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    label: 'Bawahan',
                    category: ClothingCategory.lowerBody,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    label: 'Pelengkap',
                    category: ClothingCategory.headwear,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Garment Card Tray
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isEquipped = _activeUpperBody?.id == item.id ||
                    _activeLowerBody?.id == item.id ||
                    _activeAccessory?.id == item.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildGarmentCard(
                    item: item,
                    isEquipped: isEquipped,
                    onTap: () => _equipGarment(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required ClothingCategory category,
  }) {
    final isSelected = _canvasCategoryTray == category;
    return ChoiceChip(
      label: Text(label),
      labelStyle: JText.sans(
        12,
        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? const Color(0xFF14100D) : const Color(0xFFD4C8B8),
      ),
      selected: isSelected,
      selectedColor: JColors.antiqueGold,
      backgroundColor: const Color(0xFF261D17),
      side: BorderSide(
        color: isSelected ? JColors.antiqueGold : const Color(0x33DFB76C),
        width: 0.8,
      ),
      onSelected: (val) {
        if (!val) return;
        HapticFeedback.selectionClick();
        setState(() => _canvasCategoryTray = category);
      },
    );
  }

  Widget _buildGarmentCard({
    required ClothingItem item,
    required bool isEquipped,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 124,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1612),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEquipped
                  ? JColors.antiqueGold
                  : const Color(0x33DFB76C),
              width: isEquipped ? 1.5 : 0.8,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Busana
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF261D17),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/garments/${item.id}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          item.imageAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (isEquipped)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: JColors.antiqueGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Color(0xFF14100D),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Garment Name
              Text(
                item.name,
                style: JText.serif(
                  11.5,
                  weight: isEquipped ? FontWeight.w800 : FontWeight.w600,
                  color: isEquipped
                      ? const Color(0xFFFFDF9E)
                      : const Color(0xFFFAF6F0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Region
              Text(
                item.region.title,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFFB0A290),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. SEGMENT 1: ITEM TERSIMPAN VIEW
  Widget _buildItemTersimpanView() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedGarmentsService.instance.savedItemIdsNotifier,
      builder: (context, savedIds, _) {
        final savedItems =
            SavedGarmentsService.instance.getSavedClothingItems();

        if (savedItems.isEmpty) {
          // Empty State Bersih dengan CTA Langsung ke Koleksi
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1612),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x33DFB76C),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_border_rounded,
                      size: 40,
                      color: JColors.antiqueGold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum Ada Busana Tersimpan',
                      textAlign: TextAlign.center,
                      style: JText.editorial(
                        18,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF6F0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Simpan busana adat favorit Anda dari tab Koleksi untuk memadukannya langsung di Kanvas Gaya.',
                      textAlign: TextAlign.center,
                      style: JText.sans(
                        12.5,
                        weight: FontWeight.w400,
                        color: const Color(0xFFB0A290),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: widget.onOpenCatalog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JColors.antiqueGold,
                          foregroundColor: const Color(0xFF14100D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Jelajahi Koleksi Busana',
                          style: JText.sans(
                            13,
                            weight: FontWeight.w700,
                            color: const Color(0xFF14100D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = savedItems[index];
                final isEquipped = _activeUpperBody?.id == item.id ||
                    _activeLowerBody?.id == item.id ||
                    _activeAccessory?.id == item.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1612),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isEquipped
                          ? JColors.antiqueGold
                          : const Color(0x33DFB76C),
                      width: isEquipped ? 1.2 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 58,
                          height: 58,
                          color: const Color(0xFF261D17),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'assets/garments/${item.id}.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              item.imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: JText.serif(
                                13,
                                weight: FontWeight.w700,
                                color: const Color(0xFFFAF6F0),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.category.label} • ${item.region.title}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFB0A290),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // CTA Terapkan ke Kanvas
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _equipGarment(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEquipped
                                ? const Color(0xFF35261C)
                                : JColors.antiqueGold,
                            foregroundColor: isEquipped
                                ? JColors.antiqueGold
                                : const Color(0xFF14100D),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: isEquipped
                                  ? const BorderSide(
                                      color: JColors.antiqueGold,
                                      width: 1,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: Text(
                            isEquipped ? 'Terpasang' : 'Pakai',
                            style: JText.sans(
                              11.5,
                              weight: FontWeight.w700,
                              color: isEquipped
                                  ? JColors.antiqueGold
                                  : const Color(0xFF14100D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Remove Bookmark
                      IconButton(
                        iconSize: 18,
                        icon: const Icon(
                          Icons.bookmark_remove_outlined,
                          color: Color(0xFFB0A290),
                        ),
                        tooltip: 'Hapus dari Wardrobe',
                        onPressed: () =>
                            SavedGarmentsService.instance.toggleSave(item.id),
                      ),
                    ],
                  ),
                );
              },
              childCount: savedItems.length,
            ),
          ),
        );
      },
    );
  }

  // 3. SEGMENT 2: SETELAN SAYA VIEW
  Widget _buildSetelanSayaView() {
    return ValueListenableBuilder<List<SavedOutfit>>(
      valueListenable: SavedGarmentsService.instance.savedOutfitsNotifier,
      builder: (context, outfits, _) {
        if (outfits.isEmpty) {
          // Empty State Bersih
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1612),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x33DFB76C),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.style_outlined,
                      size: 40,
                      color: JColors.antiqueGold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum Ada Setelan Tersimpan',
                      textAlign: TextAlign.center,
                      style: JText.editorial(
                        18,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF6F0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Padukan Atasan, Bawahan, dan Pelengkap di Kanvas Gaya, lalu ketuk "Simpan Setelan" untuk menyimpan kombinasi kreasi Anda.',
                      textAlign: TextAlign.center,
                      style: JText.sans(
                        12.5,
                        weight: FontWeight.w400,
                        color: const Color(0xFFB0A290),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _segmentIndex = 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JColors.antiqueGold,
                          foregroundColor: const Color(0xFF14100D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Mulai Padukan Busana',
                          style: JText.sans(
                            13,
                            weight: FontWeight.w700,
                            color: const Color(0xFF14100D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final outfit = outfits[index];

                final upper = outfit.upperBodyId.isNotEmpty
                    ? JavaneseClothingData.getItemById(outfit.upperBodyId)
                    : null;
                final lower = outfit.lowerBodyId.isNotEmpty
                    ? JavaneseClothingData.getItemById(outfit.lowerBodyId)
                    : null;
                final acc = outfit.headwearId.isNotEmpty
                    ? JavaneseClothingData.getItemById(outfit.headwearId)
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1612),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0x33DFB76C),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              outfit.customName,
                              style: JText.serif(
                                14,
                                weight: FontWeight.w700,
                                color: const Color(0xFFFAF6F0),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFF8F8073),
                            ),
                            tooltip: 'Hapus Setelan',
                            onPressed: () =>
                                SavedGarmentsService.instance.deleteOutfit(outfit.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Layer Summary
                      Text(
                        'Atasan: ${upper?.name ?? '-'}\nBawahan: ${lower?.name ?? '-'}\nPelengkap: ${acc?.name ?? '-'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB0A290),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () => _applySavedOutfitToCanvas(outfit),
                            icon: const Icon(
                              Icons.layers_rounded,
                              size: 15,
                              color: Color(0xFF14100D),
                            ),
                            label: Text(
                              'Terapkan ke Kanvas',
                              style: JText.sans(
                                12,
                                weight: FontWeight.w700,
                                color: const Color(0xFF14100D),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JColors.antiqueGold,
                              foregroundColor: const Color(0xFF14100D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: outfits.length,
            ),
          ),
        );
      },
    );
  }
}
