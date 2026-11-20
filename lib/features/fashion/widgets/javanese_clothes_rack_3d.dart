import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';

/// Callback saat baju pada gantungan 3D dipilih untuk dipakai dengan animasi
typedef OnEquipGarmentCallback = void Function(ClothingItem item, Offset hangerScreenPosition);

/// Widget Gantungan Baju 3D Berderet Tradisional Jawa ("Plangkan Busana Jati")
class JavaneseClothesRack3D extends StatefulWidget {
  const JavaneseClothesRack3D({
    super.key,
    required this.gender,
    required this.selectedUpperBody,
    required this.onEquipGarment,
    required this.onInspectGarment,
  });

  final GenderTarget gender;
  final ClothingItem? selectedUpperBody;
  final OnEquipGarmentCallback onEquipGarment;
  final ValueChanged<ClothingItem> onInspectGarment;

  @override
  State<JavaneseClothesRack3D> createState() => _JavaneseClothesRack3DState();
}

class _JavaneseClothesRack3DState extends State<JavaneseClothesRack3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swayController;
  final ScrollController _scrollController = ScrollController();
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableGarments = JavaneseClothingData.upperBodyItems
        .where((g) => g.gender == widget.gender || g.gender == GenderTarget.unisex)
        .toList();

    return Container(
      height: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF16110D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: Color(0x77E4C590), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Plangkan Busana
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2018),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE4C590), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.shelves,
                        size: 15,
                        color: Color(0xFFE4C590),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plangkan Busana Jati (Gantungan 3D)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFAF6F0),
                          ),
                        ),
                        Text(
                          'ꦥ꧀ꦭꦁꦏꦤ꧀ꦧꦸꦱꦤꦗꦮ · Sentuh baju untuk animasi pasang ke tubuh',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFFC79B3A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x33E4C590),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${availableGarments.length} BUSANA',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE4C590),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Area Rel Gantungan & Baju Berderet 3D
          Expanded(
            child: Stack(
              children: [
                // Batang Rel Gantungan Kayu Jati & Kuningan di Latar Belakang
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4A3423),
                          Color(0xFFD4AF37),
                          Color(0xFF4A3423),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Daftar Baju yang Menggantung
                ListenableBuilder(
                  listenable: _swayController,
                  builder: (context, _) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: availableGarments.length,
                      itemBuilder: (context, index) {
                        final garment = availableGarments[index];
                        final isCurrentlyWorn = widget.selectedUpperBody?.id == garment.id;
                        final isHovered = _hoveredIndex == index;

                        // Ayunan pendulum halus berbeda fase tiap gantungan
                        final swayAngle = math.sin(_swayController.value * math.pi * 2 + (index * 0.9)) * 0.04;

                        return Builder(
                          builder: (itemContext) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTapDown: (_) => setState(() => _hoveredIndex = index),
                                onTapCancel: () => setState(() => _hoveredIndex = null),
                                onTap: () {
                                  setState(() => _hoveredIndex = null);
                                  // Ambil posisi global gantungan di layar untuk koordinat animasi 3D terbang
                                  final renderBox = itemContext.findRenderObject() as RenderBox?;
                                  final screenPos = renderBox != null
                                      ? renderBox.localToGlobal(renderBox.size.center(Offset.zero))
                                      : Offset(MediaQuery.of(context).size.width / 2, 350);

                                  widget.onEquipGarment(garment, screenPos);
                                },
                                child: Transform(
                                  alignment: Alignment.topCenter,
                                  transform: Matrix4.rotationZ(swayAngle),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Kaitan Gantungan Kuningan & Hanger Kayu Jati
                                      CustomPaint(
                                        size: const Size(120, 28),
                                        painter: _HangerWoodPainter(
                                          isGlowing: isCurrentlyWorn || isHovered,
                                        ),
                                      ),

                                      // Model Baju yang Tergantung
                                      Container(
                                        width: 126,
                                        height: 104,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              garment.primaryColor,
                                              Color.lerp(garment.primaryColor, Colors.black, 0.45)!,
                                            ],
                                          ),
                                          border: Border.all(
                                            color: isCurrentlyWorn
                                                ? const Color(0xFFFFD700)
                                                : (isHovered ? const Color(0xFFE4C590) : const Color(0x44E4C590)),
                                            width: isCurrentlyWorn ? 2.0 : 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isCurrentlyWorn
                                                  ? const Color(0x66FFD700)
                                                  : const Color(0x55000000),
                                              blurRadius: isCurrentlyWorn ? 14 : 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Ilustrasi Potongan Baju & Sulam
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: _HangingGarmentDetailPainter(
                                                  garment: garment,
                                                  isWorn: isCurrentlyWorn,
                                                ),
                                              ),
                                            ),

                                            // Label Nama Busana di Kaki Baju
                                            Positioned(
                                              left: 6,
                                              right: 6,
                                              bottom: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xDD14100D),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: const Color(0x33E4C590),
                                                    width: 0.6,
                                                  ),
                                                ),
                                                child: Text(
                                                  garment.name,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFFAF6F0),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Tombol Info Budaya Pojok Kanan Atas
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: InkWell(
                                                onTap: () => widget.onInspectGarment(garment),
                                                child: Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xAA14100D),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.info_outline_rounded,
                                                    size: 13,
                                                    color: Color(0xFFE4C590),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Status 'SEDANG DIPAKAI'
                                            if (isCurrentlyWorn)
                                              Positioned(
                                                top: 4,
                                                left: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFD700),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'DIPAKAI',
                                                    style: TextStyle(
                                                      fontSize: 7.5,
                                                      fontWeight: FontWeight.w900,
                                                      color: Color(0xFF14100D),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // Aksara Jawa di Bawah Baju
                                      Text(
                                        garment.javaneseScript,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: isCurrentlyWorn
                                              ? const Color(0xFFFFD700)
                                              : const Color(0xFFA89989),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pelukis Hanger Kayu Jati & Kaitan Kuningan 3D
class _HangerWoodPainter extends CustomPainter {
  const _HangerWoodPainter({required this.isGlowing});
  final bool isGlowing;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1. Kaitan Kuningan Emas di Atas Rel
    final hookPath = Path()
      ..moveTo(cx, 16)
      ..cubicTo(cx - 8, 10, cx - 8, 2, cx, 2)
      ..cubicTo(cx + 8, 2, cx + 8, 10, cx, 16);

    canvas.drawPath(
      hookPath,
      Paint()
        ..color = isGlowing ? const Color(0xFFFFD700) : const Color(0xFFC79B3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // 2. Batang Kayu Hanger Melengkung Menyangga Pundak Baju
    final hangerPath = Path()
      ..moveTo(8, 26)
      ..quadraticBezierTo(cx, 14, size.width - 8, 26)
      ..lineTo(size.width - 8, 28)
      ..quadraticBezierTo(cx, 17, 8, 28)
      ..close();

    canvas.drawPath(
      hangerPath,
      Paint()..color = const Color(0xFF5A3E26),
    );

    canvas.drawPath(
      hangerPath,
      Paint()
        ..color = const Color(0xFF8B5A2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _HangerWoodPainter oldDelegate) =>
      oldDelegate.isGlowing != isGlowing;
}

/// Pelukis Detail Jahitan & Ornamen Baju Tradisional yang Menggantung
class _HangingGarmentDetailPainter extends CustomPainter {
  const _HangingGarmentDetailPainter({
    required this.garment,
    required this.isWorn,
  });

  final ClothingItem garment;
  final bool isWorn;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gid = garment.id;

    final accentPaint = Paint()
      ..color = garment.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (gid.contains('beskap')) {
      // Kerah Shanghai Tegak & Kancing Miring Kanan Khas Beskap
      canvas.drawLine(Offset(cx - 14, 14), Offset(cx + 14, 14), accentPaint..strokeWidth = 2.0);

      for (int i = 0; i < 4; i++) {
        final bx = cx + 8.0 - (i * 2.0);
        final by = 24.0 + (i * 14.0);
        canvas.drawCircle(Offset(bx, by), 2.8, Paint()..color = const Color(0xFFFFD700));
      }
    } else if (gid.contains('surjan')) {
      // Enam Kancing Dada Rukun Iman
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(Offset(cx, 20.0 + (i * 12.0)), 2.2, Paint()..color = garment.accentColor);
      }
    } else if (gid.contains('kartini')) {
      // Garis Leher V Panjang Khas Kebaya Kartini
      final vPath = Path()
        ..moveTo(cx - 18, 12)
        ..lineTo(cx, 58)
        ..lineTo(cx + 18, 12);
      canvas.drawPath(vPath, accentPaint..strokeWidth = 1.8);
    } else if (gid.contains('kutubaru')) {
      // Bef Dada Persegi Kebaya Kutubaru
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, 36), width: 28, height: 38),
        Paint()
          ..color = const Color(0x33E4C590)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, 36), width: 28, height: 38),
        accentPaint,
      );
    }

    // Garis Lipatan Kain Menggantung Vertikal
    final foldPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 24, 25), Offset(cx - 30, size.height - 18), foldPaint);
    canvas.drawLine(Offset(cx + 24, 25), Offset(cx + 30, size.height - 18), foldPaint);
  }

  @override
  bool shouldRepaint(covariant _HangingGarmentDetailPainter oldDelegate) =>
      oldDelegate.garment.id != garment.id || oldDelegate.isWorn != isWorn;
}
