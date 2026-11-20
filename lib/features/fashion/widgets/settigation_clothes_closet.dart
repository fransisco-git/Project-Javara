import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'javanese_garment_detail_sheet.dart';

/// Callback ketika baju di lemari Settigation dipilih untuk dipakaikan ke model
typedef OnEquipToModelCallback = void Function(ClothingItem item);

/// Widget Lemari Busana Adat Settigation ("Settigation Javanese Clothes Closet")
/// Terinspirasi dari konsep Settigation TikTok: Rel gantungan horizontal mewah,
/// pakaian tergantung rapi pada gantungan kayu, kartu tag menggantung autentik,
/// serta interaksi rotasi 360 derajat pada gantungan.
class SettigationClothesCloset extends StatefulWidget {
  const SettigationClothesCloset({
    super.key,
    required this.selectedGender,
    this.activeGarmentId,
    required this.onEquipToModel,
    this.onInspectGarment,
    this.isCompactMode = false,
  });

  final GenderTarget selectedGender;
  final String? activeGarmentId;
  final OnEquipToModelCallback onEquipToModel;
  final ValueChanged<ClothingItem>? onInspectGarment;
  final bool isCompactMode;

  @override
  State<SettigationClothesCloset> createState() => _SettigationClothesClosetState();
}

class _SettigationClothesClosetState extends State<SettigationClothesCloset>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _swayController;

  int _currentIndex = 0;
  double _currentPage = 0.0;
  double _hangerRotationY = 0.0;
  ClothingCategory _activeCategory = ClothingCategory.upperBody;
  String? _filterTag;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.isCompactMode ? 0.65 : 0.58,
      initialPage: 0,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  List<ClothingItem> _getFilteredItems() {
    final allItems = JavaneseClothingData.getItemsByCategory(_activeCategory);
    return allItems.where((item) {
      final matchesGender = item.gender == widget.selectedGender ||
          item.gender == GenderTarget.unisex;
      if (!matchesGender) return false;
      if (_filterTag == null) return true;
      return item.socialContext.label.toLowerCase().contains(_filterTag!.toLowerCase()) ||
          item.region.title.toLowerCase().contains(_filterTag!.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredItems();
    final effectiveIndex = items.isEmpty ? 0 : _currentIndex.clamp(0, items.length - 1);
    final activeItem = items.isNotEmpty ? items[effectiveIndex] : null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF130F0C),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1410),
            Color(0xFF110D0A),
            Color(0xFF0C0907),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Lemari & Filter Kategori
          _buildClosetHeader(),

          // Rel Gantungan Pakaian Settigation (Horizontal Clothes Rail)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rel Logam Tembaga & Braket Dinding Kayu Jati
                Positioned(
                  top: widget.isCompactMode ? 28 : 38,
                  left: 0,
                  right: 0,
                  child: const SettigationRailBar(),
                ),

                // Carousel Pakaian Menggantung dengan Fisika Depth & Sway
                if (items.isEmpty)
                  _buildEmptyState()
                else
                  PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _hangerRotationY = 0.0; // Reset rotasi saat berganti baju
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = index == _currentIndex;
                      final pageOffset = (_currentPage - index);

                      return _buildHangingGarment(
                        item: item,
                        isSelected: isSelected,
                        pageOffset: pageOffset,
                      );
                    },
                  ),

                // Indikator Gestur Geser & Putar 360°
                if (items.isNotEmpty && !widget.isCompactMode)
                  Positioned(
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xBB1E1712),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x55E4C590), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swipe_rounded, size: 12, color: Color(0xFFE4C590)),
                          const SizedBox(width: 5),
                          const Text(
                            'Geser rel busana • Tarik baju untuk rotasi 360°',
                            style: TextStyle(fontSize: 9.5, color: Color(0xFFFAF6F0)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Dock Kontrol & Info Kartu Settigation Aktif
          if (activeItem != null)
            _buildActiveGarmentControlPanel(activeItem),
        ],
      ),
    );
  }

  Widget _buildClosetHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: widget.isCompactMode ? 6 : 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261D16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE4C590), width: 0.8),
                    ),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      size: 14,
                      color: Color(0xFFE4C590),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLANGKAN BUSANA SETTIGATION',
                        style: JText.serif(
                          widget.isCompactMode ? 11 : 12.5,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFAF6F0),
                        ),
                      ),
                      const Text(
                        'ꦊꦩꦫꦶꦧꦸꦱꦤꦗꦮ • Koleksi Busana Berderet Autentik',
                        style: TextStyle(fontSize: 9, color: Color(0xFFDFB76C)),
                      ),
                    ],
                  ),
                ],
              ),

              // Filter Badge Tradisi
              PopupMenuButton<String?>(
                color: const Color(0xFF1E1712),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0x66E4C590)),
                ),
                initialValue: _filterTag,
                tooltip: 'Saring Asal Daerah',
                onSelected: (val) => setState(() => _filterTag = val),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Semua Busana', style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'Surakarta',
                    child: Text('Keraton Surakarta', style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'Priyayi',
                    child: Text('Priyayi & Abdi Dalem', style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'Pesisir',
                    child: Text('Pesisir & Kartini', style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'Pengantin',
                    child: Text('Upacara & Pengantin', style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12)),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF221A14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x44E4C590)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 12,
                        color: _filterTag != null ? const Color(0xFFDFB76C) : const Color(0xFFA89989),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _filterTag ?? 'Filter',
                        style: TextStyle(
                          fontSize: 10,
                          color: _filterTag != null ? const Color(0xFFDFB76C) : const Color(0xFFA89989),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tab Kategori Ricikan Busana (Atasan, Bawahan, Kepala, Aksesoris)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ClothingCategory.values.map((cat) {
                final isSelected = cat == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _activeCategory = cat;
                        _currentIndex = 0;
                        _hangerRotationY = 0.0;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFDFB76C) : const Color(0xFF1E1712),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFDFB76C) : const Color(0x33E4C590),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 11,
                            color: isSelected ? const Color(0xFF14100D) : const Color(0xFFDFB76C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF14100D) : const Color(0xFFE4C590),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHangingGarment({
    required ClothingItem item,
    required bool isSelected,
    required double pageOffset,
  }) {
    // Menghitung efek perspektif, skala kedalaman, dan kemiringan (Settigation depth)
    final scale = (1.0 - (pageOffset.abs() * 0.22)).clamp(0.75, 1.0);
    final opacity = (1.0 - (pageOffset.abs() * 0.45)).clamp(0.35, 1.0);

    // Ayunan alami gantungan baju (natural swaying physics)
    final swayOffset = math.sin(_swayController.value * 2 * math.pi + (item.hashCode % 10)) * 0.025;
    final totalRotationY = isSelected ? (_hangerRotationY + swayOffset) : swayOffset;

    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onHorizontalDragUpdate: isSelected
                  ? (details) {
                      setState(() {
                        _hangerRotationY += details.primaryDelta! * 0.018;
                      });
                    }
                  : null,
              onDoubleTap: isSelected
                  ? () {
                      setState(() {
                        _hangerRotationY = 0.0;
                      });
                    }
                  : null,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Kait Gantungan Logam di atas rel
                  Positioned(
                    top: widget.isCompactMode ? 14 : 22,
                    child: const MetallicHangerHook(),
                  ),

                  // Gantungan Kayu Jati Melengkung
                  Positioned(
                    top: widget.isCompactMode ? 32 : 44,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(totalRotationY),
                      alignment: Alignment.center,
                      child: TeakWoodHanger(
                        width: widget.isCompactMode ? 140 : 170,
                      ),
                    ),
                  ),

                  // Kartu Tag Autentik Settigation Menggantung (Dangling Tag)
                  Positioned(
                    top: widget.isCompactMode ? 55 : 70,
                    right: widget.isCompactMode ? 10 : 15,
                    child: SettigationDanglingTag(
                      item: item,
                      rotation: swayOffset * 1.8,
                    ),
                  ),

                  // Busana Utama yang Tergantung dengan Rotasi 3D
                  Positioned(
                    top: widget.isCompactMode ? 50 : 66,
                    bottom: widget.isCompactMode ? 8 : 12,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(totalRotationY),
                      alignment: Alignment.center,
                      child: GarmentVisualCloth(
                        item: item,
                        rotationY: totalRotationY,
                        isCompact: widget.isCompactMode,
                      ),
                    ),
                  ),

                  // Indikator Garment Terpasang pada Model
                  if (widget.activeGarmentId == item.id)
                    Positioned(
                      top: widget.isCompactMode ? 36 : 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E6F5C),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF70AF85), width: 0.8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x551E6F5C), blurRadius: 6),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 10, color: Color(0xFFFAF6F0)),
                            SizedBox(width: 3),
                            Text(
                              'SEDANG DIPAKAI',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFAF6F0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveGarmentControlPanel(ClothingItem item) {
    final isEquipped = widget.activeGarmentId == item.id;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        widget.isCompactMode ? 8 : 12,
        16,
        widget.isCompactMode ? 10 : 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF17120E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: Color(0x66DFB76C), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama Busana, Asal, & Periode Era
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: JText.serif(
                            widget.isCompactMode ? 13 : 14.5,
                            weight: FontWeight.w700,
                            color: const Color(0xFFFAF6F0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.region.title} • ${item.socialContext.label} • ${item.period}',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFFDFB76C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tombol Putar 360 Cepat
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Reset Sudut Putar',
                icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFFDFB76C)),
                onPressed: () {
                  setState(() => _hangerRotationY = 0.0);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tombol Aksi: Pakaikan ke Model Peraga & Detail Filosofi
          Row(
            children: [
              // Detail Filosofi
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFAF6F0),
                    side: const BorderSide(color: Color(0x55DFB76C), width: 0.9),
                    backgroundColor: const Color(0xFF221A14),
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isCompactMode ? 8 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.auto_stories_rounded, size: 13, color: Color(0xFFDFB76C)),
                  label: Text(
                    'Filosofi Busana',
                    style: TextStyle(
                      fontSize: widget.isCompactMode ? 10.5 : 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),
                  onPressed: () {
                    if (widget.onInspectGarment != null) {
                      widget.onInspectGarment!(item);
                    } else {
                      JavaneseGarmentDetailSheet.show(context, item);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Pakaikan ke Model Peraga
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEquipped ? const Color(0xFF1E6F5C) : const Color(0xFFDFB76C),
                    foregroundColor: isEquipped ? const Color(0xFFFAF6F0) : const Color(0xFF14100D),
                    padding: EdgeInsets.symmetric(
                      vertical: widget.isCompactMode ? 8 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(
                    isEquipped ? Icons.check_circle_rounded : Icons.accessibility_new_rounded,
                    size: 14,
                    color: isEquipped ? const Color(0xFFFAF6F0) : const Color(0xFF14100D),
                  ),
                  label: Text(
                    isEquipped ? 'Sedang Dipakai' : 'Pakaikan ke Model',
                    style: TextStyle(
                      fontSize: widget.isCompactMode ? 10.5 : 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onPressed: () {
                    widget.onEquipToModel(item);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shelves, size: 36, color: Color(0x66DFB76C)),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada busana untuk filter terpilih',
            style: TextStyle(fontSize: 11, color: Color(0xFFA89989)),
          ),
          TextButton(
            onPressed: () => setState(() => _filterTag = null),
            child: const Text('Reset Filter', style: TextStyle(color: Color(0xFFDFB76C), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// Rel Gantungan Logam Settigation Horizontal (Horizontal Clothes Rail)
class SettigationRailBar extends StatelessWidget {
  const SettigationRailBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Batang Rel Logam Kuningan/Tembaga Berkilau
          Container(
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.5),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5A442E),
                  Color(0xFFDFB76C),
                  Color(0xFFFFEEBA),
                  Color(0xFFDFB76C),
                  Color(0xFF5A442E),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
                BoxShadow(
                  color: Color(0x33DFB76C),
                  blurRadius: 8,
                ),
              ],
            ),
          ),

          // Braket Dinding Kayu Jati Kiri
          Positioned(
            left: 0,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2016),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFDFB76C), width: 1.0),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEBA),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Braket Dinding Kayu Jati Kanan
          Positioned(
            right: 0,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2016),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFDFB76C), width: 1.0),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEBA),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kait Gantungan Baju Logam (Metallic Hanger Hook)
class MetallicHangerHook extends StatelessWidget {
  const MetallicHangerHook({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 28),
      painter: _MetallicHookPainter(),
    );
  }
}

class _MetallicHookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hookPaint = Paint()
      ..color = const Color(0xFFE8C88A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Melengkung melintasi rel di atas
    path.moveTo(size.width * 0.75, size.height * 0.2);
    path.cubicTo(
      size.width * 0.85,
      0,
      size.width * 0.2,
      0,
      size.width * 0.3,
      size.height * 0.5,
    );
    path.lineTo(size.width * 0.5, size.height);

    canvas.drawPath(path, hookPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gantungan Kayu Jati Melengkung (Teak Wood Hanger)
class TeakWoodHanger extends StatelessWidget {
  const TeakWoodHanger({super.key, required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 24),
      painter: _TeakHangerPainter(),
    );
  }
}

class _TeakHangerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final woodGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF8A5D3B),
        Color(0xFF53331C),
        Color(0xFF381F0E),
      ],
    );

    final woodPaint = Paint()
      ..shader = woodGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFC49658)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    // Lengkungan segitiga gantungan kayu
    path.moveTo(size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.25, 4, 0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.05, size.height, size.width * 0.15, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.quadraticBezierTo(size.width * 0.95, size.height, size.width, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.75, 4, size.width * 0.5, 0);
    path.close();

    canvas.drawPath(path, woodPaint);
    canvas.drawPath(path, borderPaint);

    // Titik tumpu tengah gantungan (Center brass rivet)
    final rivetPaint = Paint()..color = const Color(0xFFFFEEBA);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), 2.2, rivetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kartu Tag Autentik Settigation Menggantung (Settigation Dangling Tag)
class SettigationDanglingTag extends StatelessWidget {
  const SettigationDanglingTag({
    super.key,
    required this.item,
    required this.rotation,
  });

  final ClothingItem item;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tali gantungan tag
          Container(
            width: 1.2,
            height: 14,
            color: const Color(0xFFC49658),
          ),

          // Badan kartu tag mewah
          Container(
            width: 78,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1712),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFDFB76C), width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFB76C),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'JAVARA',
                        style: TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF14100D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(Icons.verified_rounded, size: 7, color: Color(0xFFDFB76C)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.region.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFAF6F0),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.period,
                  style: const TextStyle(fontSize: 5.5, color: Color(0xFFA89989)),
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                // Kode Bar Mini
                Container(
                  height: 4,
                  color: const Color(0x33DFB76C),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      10,
                      (i) => Container(
                        width: i % 2 == 0 ? 1 : 1.5,
                        color: const Color(0xFFFAF6F0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Representasi Visual Kain Busana Menggantung (Garment Visual Cloth)
class GarmentVisualCloth extends StatelessWidget {
  const GarmentVisualCloth({
    super.key,
    required this.item,
    required this.rotationY,
    required this.isCompact,
  });

  final ClothingItem item;
  final double rotationY;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final width = isCompact ? 135.0 : 160.0;
    final height = isCompact ? 160.0 : 210.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Gambar / Siluet Busana Adat
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1611),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x33DFB76C), width: 0.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fallback Siluet Artistik Busana Tradisional
                  CustomPaint(
                    painter: _GarmentSilhouettePainter(
                      category: item.category,
                      primaryColor: item.primaryColor,
                      accentColor: item.accentColor,
                      rotationY: rotationY,
                    ),
                  ),

                  // Pencahayaan Dinamis Berdasarkan Sudut Rotasi 360°
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(math.cos(rotationY), -1.0),
                        end: Alignment(-math.cos(rotationY), 1.0),
                        colors: [
                          Colors.white.withValues(alpha: (0.15 * (math.sin(rotationY) + 1.0)).clamp(0.0, 0.25)),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),

                  // Badge Tipe & Filosofi Singkat
                  Positioned(
                    bottom: 8,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xDD14100D),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x44DFB76C), width: 0.6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFAF6F0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.material,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFFDFB76C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pelukis Siluet Busana Adat Tradisional Jawa (Beskap, Kebaya, Surjan, dsb)
class _GarmentSilhouettePainter extends CustomPainter {
  _GarmentSilhouettePainter({
    required this.category,
    required this.primaryColor,
    required this.accentColor,
    required this.rotationY,
  });

  final ClothingCategory category;
  final Color primaryColor;
  final Color accentColor;
  final double rotationY;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = primaryColor;
    final goldPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();
    final width = size.width;
    final height = size.height;

    switch (category) {
      case ClothingCategory.upperBody:
        // Pola Busana Atasan (Beskap / Kebaya / Surjan)
        path.moveTo(width * 0.25, height * 0.12);
        path.lineTo(width * 0.08, height * 0.38); // Lengan Kiri
        path.lineTo(width * 0.22, height * 0.44);
        path.lineTo(width * 0.25, height * 0.85); // Badan Kiri
        path.lineTo(width * 0.75, height * 0.85); // Bawah
        path.lineTo(width * 0.78, height * 0.44); // Badan Kanan
        path.lineTo(width * 0.92, height * 0.38); // Lengan Kanan
        path.lineTo(width * 0.75, height * 0.12);
        path.quadraticBezierTo(width * 0.5, height * 0.18, width * 0.25, height * 0.12); // Kerah
        path.close();
        canvas.drawPath(path, bgPaint);
        canvas.drawPath(path, goldPaint);

        // Kancing & Sulaman Tengah
        final buttonPaint = Paint()..color = accentColor;
        for (int i = 0; i < 5; i++) {
          final dy = height * (0.24 + (i * 0.11));
          canvas.drawCircle(Offset(width * 0.5, dy), 2.2, buttonPaint);
        }
        break;

      case ClothingCategory.lowerBody:
        // Pola Bebetan Jarik Batik dengan Wiron
        path.moveTo(width * 0.25, height * 0.10);
        path.lineTo(width * 0.20, height * 0.88);
        path.lineTo(width * 0.80, height * 0.88);
        path.lineTo(width * 0.75, height * 0.10);
        path.close();
        canvas.drawPath(path, bgPaint);
        canvas.drawPath(path, goldPaint);

        // Lipatan Wiron Jarik Vertikal
        final foldPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        for (int i = 0; i < 4; i++) {
          final dx = width * (0.42 + (i * 0.07));
          canvas.drawLine(Offset(dx, height * 0.12), Offset(dx, height * 0.86), foldPaint);
        }
        break;

      case ClothingCategory.headwear:
        // Pola Blangkon / Sanggul Tekuk
        path.moveTo(width * 0.25, height * 0.45);
        path.cubicTo(width * 0.25, height * 0.20, width * 0.75, height * 0.20, width * 0.75, height * 0.45);
        path.quadraticBezierTo(width * 0.5, height * 0.55, width * 0.25, height * 0.45);
        path.close();
        canvas.drawPath(path, bgPaint);
        canvas.drawPath(path, goldPaint);
        break;

      case ClothingCategory.accessories:
        // Keris Ladrang / Bros Susun
        final kerisPath = Path();
        kerisPath.moveTo(width * 0.5, height * 0.15);
        kerisPath.lineTo(width * 0.55, height * 0.75);
        kerisPath.lineTo(width * 0.48, height * 0.82);
        kerisPath.close();
        canvas.drawPath(kerisPath, goldPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GarmentSilhouettePainter oldDelegate) {
    return oldDelegate.rotationY != rotationY ||
        oldDelegate.category != category ||
        oldDelegate.primaryColor != primaryColor;
  }
}
