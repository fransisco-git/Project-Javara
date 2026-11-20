import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/javanese_clothing_models.dart';

/// Sikap / Pose Manekin 3D
enum MannequinPose {
  ngadegSiaga('Ngadeg Siaga', 'Berdiri tegak wibawa ksatria'),
  santunJawa('Santun Ngurmati', 'Sikap tangan santun di pusar'),
  sikapSembah('Sembah Pangabekti', 'Kedua tangan menangkup di dada');

  const MannequinPose(this.label, this.description);
  final String label;
  final String description;
}

/// Mode Penataan Kamera 3D
enum CameraPreset {
  depan('Depan (Full)', 0.0, 0.0, 1.0, Offset(0, 10)),
  sampingKanan('Samping Kanan', math.pi / 2, 0.04, 1.1, Offset(0, 15)),
  belakangKeris('Belakang (Keris)', math.pi, -0.05, 1.15, Offset(0, 20)),
  sampingKiri('Samping Kiri', -math.pi / 2, 0.04, 1.1, Offset(0, 15)),
  closeupKepala('Close-up Iketan', 0.15, -0.15, 1.85, Offset(0, 180)),
  detailBatik('Detail Jarik', 0.25, 0.15, 1.7, Offset(0, -90));

  const CameraPreset(this.label, this.yaw, this.pitch, this.zoom, this.panOffset);
  final String label;
  final double yaw;
  final double pitch;
  final double zoom;
  final Offset panOffset;
}

/// Controller Interaktif Ruang 3D Manekin Busana Adat
class Wardrobe3DController extends ChangeNotifier {
  double _yaw = 0.0; // Rotasi horizontal azimuth 360°
  double _pitch = 0.05; // Sudut elevasi kamera
  double _zoom = 1.0; // Skala pembesaran
  Offset _pan = Offset.zero; // Pergeseran lateral
  bool _isWireframe = false; // Mode cetak biru kawat emas
  MannequinPose _pose = MannequinPose.ngadegSiaga;

  double get yaw => _yaw;
  double get pitch => _pitch;
  double get zoom => _zoom;
  Offset get pan => _pan;
  bool get isWireframe => _isWireframe;
  MannequinPose get pose => _pose;

  void rotate(double deltaX, double deltaY) {
    _yaw = (_yaw + deltaX * 0.012) % (math.pi * 2);
    _pitch = (_pitch + deltaY * 0.008).clamp(-0.45, 0.65);
    notifyListeners();
  }

  void setZoom(double newZoom) {
    _zoom = newZoom.clamp(0.7, 2.6);
    notifyListeners();
  }

  void panDelta(Offset delta) {
    _pan = Offset(
      (_pan.dx + delta.dx).clamp(-120.0, 120.0),
      (_pan.dy + delta.dy).clamp(-200.0, 200.0),
    );
    notifyListeners();
  }

  void applyPreset(CameraPreset preset) {
    _yaw = preset.yaw;
    _pitch = preset.pitch;
    _zoom = preset.zoom;
    _pan = preset.panOffset;
    notifyListeners();
  }

  void setPose(MannequinPose newPose) {
    _pose = newPose;
    notifyListeners();
  }

  void toggleWireframe() {
    _isWireframe = !_isWireframe;
    notifyListeners();
  }

  void resetCamera() {
    _yaw = 0.0;
    _pitch = 0.05;
    _zoom = 1.0;
    _pan = Offset.zero;
    notifyListeners();
  }
}

/// Widget Viewport Manekin 3D Interaktif Studio Busana Adat
class Wardrobe3DViewport extends StatefulWidget {
  const Wardrobe3DViewport({
    super.key,
    required this.controller,
    required this.gender,
    required this.selectedHeadwear,
    required this.selectedUpperBody,
    required this.selectedLowerBody,
    required this.selectedAccessories,
    required this.onGarmentTapped,
    this.highlightedCategory,
    this.animatingGarment,
    this.equipProgress = 0.0,
    this.equipSourcePos = Offset.zero,
  });

  final Wardrobe3DController controller;
  final GenderTarget gender;
  final ClothingItem? selectedHeadwear;
  final ClothingItem? selectedUpperBody;
  final ClothingItem? selectedLowerBody;
  final List<ClothingItem> selectedAccessories;
  final ValueChanged<ClothingItem> onGarmentTapped;
  final ClothingCategory? highlightedCategory;

  // Parameter Animasi 3D Terbang Baju dari Gantungan ke Avatar
  final ClothingItem? animatingGarment;
  final double equipProgress;
  final Offset equipSourcePos;

  @override
  State<Wardrobe3DViewport> createState() => _Wardrobe3DViewportState();
}

class _Wardrobe3DViewportState extends State<Wardrobe3DViewport>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleAnimController;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _idleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnimController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    final cy = size.height / 2 + widget.controller.pan.dy;
    final normalizedY = (localPosition.dy - cy) / widget.controller.zoom;

    // Raycast hit-detection berdasarkan zona anatomi vertikal
    if (normalizedY < -110 && widget.selectedHeadwear != null) {
      widget.onGarmentTapped(widget.selectedHeadwear!);
    } else if (normalizedY >= -110 && normalizedY < 20 && widget.selectedUpperBody != null) {
      widget.onGarmentTapped(widget.selectedUpperBody!);
    } else if (normalizedY >= 20 && normalizedY < 170 && widget.selectedLowerBody != null) {
      widget.onGarmentTapped(widget.selectedLowerBody!);
    } else if (normalizedY >= 170 && widget.selectedAccessories.isNotEmpty) {
      widget.onGarmentTapped(widget.selectedAccessories.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = widget.controller.zoom;
      },
      onScaleUpdate: (details) {
        if (details.pointerCount == 1) {
          widget.controller.rotate(
            details.focalPointDelta.dx,
            details.focalPointDelta.dy,
          );
        } else if (details.pointerCount >= 2) {
          widget.controller.setZoom(_baseScale * details.scale);
          widget.controller.panDelta(details.focalPointDelta * 0.8);
        }
      },
      onTapUp: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          _handleTap(details.localPosition, renderBox.size);
        }
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.controller, _idleAnimController]),
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _Wardrobe3DMannequinPainter(
              yaw: widget.controller.yaw,
              pitch: widget.controller.pitch,
              zoom: widget.controller.zoom,
              pan: widget.controller.pan,
              isWireframe: widget.controller.isWireframe,
              pose: widget.controller.pose,
              idleT: _idleAnimController.value,
              gender: widget.gender,
              headwear: widget.selectedHeadwear,
              upperBody: widget.selectedUpperBody,
              lowerBody: widget.selectedLowerBody,
              accessories: widget.selectedAccessories,
              highlightedCategory: widget.highlightedCategory,
              animatingGarment: widget.animatingGarment,
              equipProgress: widget.equipProgress,
              equipSourcePos: widget.equipSourcePos,
            ),
          );
        },
      ),
    );
  }
}

/// Pelukis Kanvas 3D Manekin Hiper-Realistis & Busana Tradisional Jawa (Custom 3D Engine)
class _Wardrobe3DMannequinPainter extends CustomPainter {
  const _Wardrobe3DMannequinPainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.pan,
    required this.isWireframe,
    required this.pose,
    required this.idleT,
    required this.gender,
    required this.headwear,
    required this.upperBody,
    required this.lowerBody,
    required this.accessories,
    required this.highlightedCategory,
    this.animatingGarment,
    this.equipProgress = 0.0,
    this.equipSourcePos = Offset.zero,
  });

  final double yaw;
  final double pitch;
  final double zoom;
  final Offset pan;
  final bool isWireframe;
  final MannequinPose pose;
  final double idleT;
  final GenderTarget gender;
  final ClothingItem? headwear;
  final ClothingItem? upperBody;
  final ClothingItem? lowerBody;
  final List<ClothingItem> accessories;
  final ClothingCategory? highlightedCategory;

  final ClothingItem? animatingGarment;
  final double equipProgress;
  final Offset equipSourcePos;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + pan.dx;
    final cy = size.height / 2 + pan.dy;

    // Gerak napas halus (idle breathing oscillation)
    final breathOffset = math.sin(idleT * math.pi * 2) * 2.2;

    // -------------------------------------------------------------------------
    // 1. LATAR BELAKANG STUDIO PAMERAN & PEDESTAL MARMER KAYU JATI
    // -------------------------------------------------------------------------
    _drawStudioAmbiance(canvas, size, cx, cy);

    // -------------------------------------------------------------------------
    // 2. FUNGSI PROYEKSI MATEMATIKA 3D (YAW & PITCH MATRIX)
    // -------------------------------------------------------------------------
    Offset project(double x, double y, double z) {
      // Rotasi Y (Azimuth / Yaw)
      final cosY = math.cos(yaw);
      final sinY = math.sin(yaw);
      final rx = x * cosY - z * sinY;
      final rz = x * sinY + z * cosY;

      // Rotasi X (Pitch)
      final cosX = math.cos(pitch);
      final sinX = math.sin(pitch);
      final ry = y * cosX - rz * sinX;
      final rzFinal = y * sinX + rz * cosX;

      // Proyeksi Perspektif Lembut dengan Lensa 650mm
      final distance = 650.0;
      final scaleFactor = (distance / (distance + rzFinal)) * zoom;

      return Offset(cx + rx * scaleFactor, cy + ry * scaleFactor);
    }

    double getDepth(double x, double y, double z) {
      final sinY = math.sin(yaw);
      final cosY = math.cos(yaw);
      final rz = x * sinY + z * cosY;
      final sinX = math.sin(pitch);
      final cosX = math.cos(pitch);
      return y * sinX + rz * cosX;
    }

    // -------------------------------------------------------------------------
    // 3. PEDESTAL PODIUM KAYU UKIR TEMPAT MANEKIN BERDIRI
    // -------------------------------------------------------------------------
    _drawOrnatePedestal(canvas, project, cy);

    // -------------------------------------------------------------------------
    // 4. ANATOMI MANEKIN & LAPISAN BUSANA DENGAN DEPTH SORTING REALISTIS
    // -------------------------------------------------------------------------
    final isFacingFront = math.cos(yaw) > 0.0;
    final isFacingRear = math.cos(yaw) < -0.2;

    // 4A. Lapisan Belakang (Jika membelakangi kamera: Keris & Punggung)
    if (isFacingRear) {
      _drawKerisPusaka(canvas, project, isBackView: true);
    }

    // 4B. Kaki & Selop Tradisional Realistis (Feet & Slippers)
    _drawFeetAndSelop(canvas, project, getDepth);

    // 4C. Busana Bawahan: Kain Jarik Batik Tradisi Berwiru 3D
    _drawLowerBodyJarik(canvas, project, getDepth);

    // 4D. Tubuh Inti Manekin & Busana Atasan Hiper-Realistis
    _drawUpperBody(canvas, project, getDepth, breathOffset);

    // 4E. Sabuk Cinde, Epek & Timang Emas Sepuh 3D
    _drawWaistAccessories(canvas, project, getDepth);

    // 4F. Jika Menghadap Depan: Keris Diselipkan di Belakang (terlihat ujung warangka ladrang)
    if (!isFacingRear) {
      _drawKerisPusaka(canvas, project, isBackView: false);
    }

    // 4G. Perhiasan Dada: Kalung Ulur & Bros Rodha (Untuk Kebaya Putri)
    if (isFacingFront && gender == GenderTarget.wanita) {
      _drawChestJewelry(canvas, project, breathOffset);
    }

    // 4H. Kepala & Penutup Kepala Realistis (Blangkon / Kuluk / Sanggul Tekuk Melati)
    _drawHeadwear(canvas, project, getDepth, breathOffset);

    // 4I. Indikator Hotspot Interaktif yang Dipilih
    if (highlightedCategory != null) {
      _drawCategoryHighlightPin(canvas, project, highlightedCategory!, breathOffset);
    }

    // 4J. Animasi 3D Baju Terbang dari Gantungan Baju ke Avatar
    if (animatingGarment != null && equipProgress > 0.0 && equipProgress < 1.0) {
      _draw3DFlyingEquipAnimation(canvas, project, size, cx, cy);
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: AMBIANCE STUDIO & LANTAI PAMERAN
  // ---------------------------------------------------------------------------
  void _drawStudioAmbiance(Canvas canvas, Size size, double cx, double cy) {
    // Sorotan Ambient Spotlight Emas Mewah di Balik Manekin
    final spotlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy - 40),
        size.height * 0.55,
        [
          const Color(0x38E4C590),
          const Color(0x12E4C590),
          Colors.transparent,
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(Offset.zero & size, spotlightPaint);

    // Garis Kisi Lantai Studio Elips Perspektif
    final floorPaint = Paint()
      ..color = const Color(0x28E4C590)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final floorCenter = Offset(cx, cy + 225);
    for (int r = 1; r <= 3; r++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: floorCenter,
          width: 260.0 * r * 0.45 * zoom,
          height: 60.0 * r * 0.45 * zoom,
        ),
        floorPaint,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: PEDESTAL PODIUM UKIR
  // ---------------------------------------------------------------------------
  void _drawOrnatePedestal(Canvas canvas, Offset Function(double, double, double) project, double cy) {
    const pRadius = 110.0;
    const pHeight = 220.0;
    final pPath = Path();
    const segs = 16;

    for (int i = 0; i <= segs; i++) {
      final theta = (i / segs) * math.pi * 2;
      final px = math.cos(theta) * pRadius;
      final pz = math.sin(theta) * (pRadius * 0.65);
      final pt = project(px, pHeight, pz);
      if (i == 0) {
        pPath.moveTo(pt.dx, pt.dy);
      } else {
        pPath.lineTo(pt.dx, pt.dy);
      }
    }
    pPath.close();

    final pedPaint = Paint()
      ..color = isWireframe ? const Color(0x44E4C590) : const Color(0xFF231913)
      ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    canvas.drawPath(pPath, pedPaint);

    final borderPaint = Paint()
      ..color = const Color(0x77E4C590)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(pPath, borderPaint);
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: KAKI & SELOP TRADISIONAL REALISTIS
  // ---------------------------------------------------------------------------
  void _drawFeetAndSelop(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double Function(double, double, double) getDepth,
  ) {
    const feetY = 195.0;
    final feetX = [-24.0, 24.0];

    final selopColor = accessories.any((a) => a.id.contains('selop'))
        ? const Color(0xFF141210)
        : const Color(0xFF382A1E);

    final goldTrim = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (final fx in feetX) {
      // Shading Kaki / Pergelangan Kaki (Ankles)
      final ankleCenter = project(fx, feetY - 4, 0);
      canvas.drawCircle(
        ankleCenter,
        6.5 * zoom,
        Paint()..color = const Color(0xFFC69468),
      );

      // Selop Beludru 3D dengan Bentuk Melengkung Halus & Tumit Berlapis
      final toe = project(fx, feetY + 12, 18);
      final heel = project(fx, feetY + 10, -14);
      final leftSide = project(fx - 11, feetY + 11, 2);
      final rightSide = project(fx + 11, feetY + 11, 2);

      final footPath = Path()
        ..moveTo(toe.dx, toe.dy)
        ..cubicTo(rightSide.dx, rightSide.dy + 2, heel.dx + 4, heel.dy, heel.dx, heel.dy)
        ..cubicTo(heel.dx - 4, heel.dy, leftSide.dx, leftSide.dy + 2, toe.dx, toe.dy)
        ..close();

      // Badan Selop Beludru Hitam
      canvas.drawPath(
        footPath,
        Paint()
          ..color = isWireframe ? const Color(0x55E4C590) : selopColor
          ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
      );
      canvas.drawPath(footPath, goldTrim);

      // Sulaman Bunga Prada Emas di Ujung Selop
      if (!isWireframe) {
        final embCenter = project(fx, feetY + 10, 10);
        canvas.drawCircle(embCenter, 2.8, Paint()..color = const Color(0xFFFFD700));
        canvas.drawCircle(embCenter, 1.0, Paint()..color = const Color(0xFF14100D));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: KAIN JARIK BATIK BERWIRU 3D & BERLIPAT DINAMIS
  // ---------------------------------------------------------------------------
  void _drawLowerBodyJarik(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double Function(double, double, double) getDepth,
  ) {
    const topY = 25.0;
    const botY = 195.0;
    const topW = 48.0;
    const botW = 68.0;
    const depthW = 26.0;

    // Kontur Silinder Jarik yang Menggantung Alami ke Bawah
    final pTopLeft = project(-topW, topY, 0);
    final pTopRight = project(topW, topY, 0);
    final pBotRight = project(botW, botY, 0);
    final pBotMid = project(0, botY + 4, 12);
    final pBotLeft = project(-botW, botY, 0);

    final jarikPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..cubicTo(pTopRight.dx + 6, topY + 70, pBotRight.dx + 8, botY - 30, pBotRight.dx, pBotRight.dy)
      ..quadraticBezierTo(pBotMid.dx, pBotMid.dy, pBotLeft.dx, pBotLeft.dy)
      ..cubicTo(pBotLeft.dx - 8, botY - 30, pTopLeft.dx - 6, topY + 70, pTopLeft.dx, pTopLeft.dy)
      ..close();

    final jarikBaseColor = lowerBody?.primaryColor ?? const Color(0xFF2C1E12);
    final accentGoldColor = lowerBody?.accentColor ?? const Color(0xFFE4C590);

    // Isian Warna Dasar Jarik Sogan dengan Gradasi Bayangan Alami
    canvas.drawPath(
      jarikPath,
      Paint()
        ..shader = isWireframe
            ? null
            : ui.Gradient.linear(
                pTopLeft,
                pBotRight,
                [
                  Color.lerp(jarikBaseColor, Colors.white, 0.08)!,
                  jarikBaseColor,
                  Color.lerp(jarikBaseColor, Colors.black, 0.35)!,
                ],
              )
        ..color = isWireframe ? const Color(0x33E4C590) : jarikBaseColor
        ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
    );

    // Ragam Pola Batik Matematis Autentik pada Jarik
    if (!isWireframe) {
      _drawAuthenticBatikPattern(
        canvas,
        project,
        lowerBody?.id ?? 'jarik_batik_parang_barong_solo',
        topY,
        botY,
        topW,
        botW,
        accentGoldColor,
      );
    }

    // Wiru Lipatan Khas Jawa di Bagian Depan Jarik (7 Lipatan Bersusun dengan Efek Kedalaman)
    final isFacingFront = math.cos(yaw) > -0.2;
    if (isFacingFront) {
      const wiruCount = 7;
      for (int i = 0; i < wiruCount; i++) {
        final wx = -14.0 + (i * 3.6);
        final wTop = project(wx, topY, depthW);
        final wBot = project(wx - 5, botY + 2, depthW);

        // Bayangan di Balik Tiap Lipatan Wiru
        canvas.drawLine(
          Offset(wTop.dx + 1.2, wTop.dy),
          Offset(wBot.dx + 1.2, wBot.dy),
          Paint()
            ..color = const Color(0x66000000)
            ..strokeWidth = 2.0,
        );

        // Garis Lipatan Wiru Beraksen Emas Cerah
        canvas.drawLine(
          wTop,
          wBot,
          Paint()
            ..color = accentGoldColor.withValues(alpha: 0.95)
            ..strokeWidth = 1.6,
        );
      }
    }

    // Garis Kontur Luar Jarik
    canvas.drawPath(
      jarikPath,
      Paint()
        ..color = const Color(0x77DFB76C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  // ---------------------------------------------------------------------------
  // POLA BATIK MATEMATIS (PARANG, KAWUNG, TRUNTUM, SIDOMUKTI)
  // ---------------------------------------------------------------------------
  void _drawAuthenticBatikPattern(
    Canvas canvas,
    Offset Function(double, double, double) project,
    String lowerId,
    double topY,
    double botY,
    double topW,
    double botW,
    Color accentColor,
  ) {
    final patternPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.42)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    if (lowerId.contains('parang')) {
      // Pola Lereng Diagonal Parang 45 Derajat dengan Mlinjon
      for (double y = topY + 10; y <= botY; y += 22) {
        final t = (y - topY) / (botY - topY);
        final curW = topW + (botW - topW) * t;

        final p1 = project(-curW * 0.85, y, 10);
        final p2 = project(curW * 0.85, y + 16, 10);
        canvas.drawLine(p1, p2, patternPaint);

        // Mlinjon belah ketupat di lereng parang
        final mid = project(0, y + 8, 12);
        canvas.drawCircle(mid, 3.0, dotPaint);
      }
    } else if (lowerId.contains('kawung')) {
      // Pola Geometris Empat Elips Buah Aren Kawung
      for (double y = topY + 14; y <= botY; y += 24) {
        for (double x = -40; x <= 40; x += 22) {
          final pt = project(x, y, 10);
          canvas.drawCircle(pt, 4.4, patternPaint);
          canvas.drawCircle(pt, 1.6, dotPaint);
        }
      }
    } else if (lowerId.contains('truntum')) {
      // Pola Taburan Bintang Kuncup Melati Truntum
      for (double y = topY + 10; y <= botY; y += 18) {
        for (double x = -45; x <= 45; x += 18) {
          final pt = project(x, y, 10);
          canvas.drawCircle(pt, 2.0, dotPaint);
          // 4 titik daun kembang mini
          canvas.drawCircle(Offset(pt.dx - 2.8, pt.dy), 1.0, dotPaint);
          canvas.drawCircle(Offset(pt.dx + 2.8, pt.dy), 1.0, dotPaint);
          canvas.drawCircle(Offset(pt.dx, pt.dy - 2.8), 1.0, dotPaint);
          canvas.drawCircle(Offset(pt.dx, pt.dy + 2.8), 1.0, dotPaint);
        }
      }
    } else {
      // Garis Isen-Isen Klasik Tradisional Solo
      for (double y = topY + 15; y <= botY; y += 20) {
        final p1 = project(-40, y, 10);
        final p2 = project(40, y, 10);
        canvas.drawLine(p1, p2, patternPaint);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: ANATOMI TUBUH & BUSANA ATASAN HIPER-REALISTIS
  // ---------------------------------------------------------------------------
  void _drawUpperBody(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double Function(double, double, double) getDepth,
    double breath,
  ) {
    final topY = -82.0 + breath;
    const botY = 28.0;
    const shoulderW = 60.0;
    const waistW = 42.0;

    // Shading Klavikula / Tulang Selangka di Leher Bawah
    final isFacingFront = math.cos(yaw) > -0.2;
    if (isFacingFront && !isWireframe) {
      final clavL = project(-22, topY - 4, 10);
      final clavMid = project(0, topY + 4, 12);
      final clavR = project(22, topY - 4, 10);
      final clavPath = Path()
        ..moveTo(clavL.dx, clavL.dy)
        ..quadraticBezierTo(clavL.dx + 10, clavL.dy + 6, clavMid.dx, clavMid.dy)
        ..quadraticBezierTo(clavR.dx - 10, clavR.dy + 6, clavR.dx, clavR.dy);

      canvas.drawPath(
        clavPath,
        Paint()
          ..color = const Color(0x55000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Bentuk Tailoring Jas Beskap / Kebaya dengan Lekukan Pundak & Pinggang Realistis
    final pTopLeft = project(-shoulderW, topY, 0);
    final pTopRight = project(shoulderW, topY, 0);
    final pWaistRight = project(waistW, botY, 0);
    final pWaistLeft = project(-waistW, botY, 0);

    final upperPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..cubicTo(pTopRight.dx + 4, topY + 35, pWaistRight.dx + 6, botY - 15, pWaistRight.dx, pWaistRight.dy)
      ..lineTo(pWaistLeft.dx, pWaistLeft.dy)
      ..cubicTo(pWaistLeft.dx - 6, botY - 15, pTopLeft.dx - 4, topY + 35, pTopLeft.dx, pTopLeft.dy)
      ..close();

    final upperBaseColor = upperBody?.primaryColor ?? const Color(0xFF1C1814);
    final upperAccentColor = upperBody?.accentColor ?? const Color(0xFFE4C590);

    // Isian Kain dengan Gradasi Bayangan Studio Realistis
    canvas.drawPath(
      upperPath,
      Paint()
        ..shader = isWireframe
            ? null
            : ui.Gradient.linear(
                pTopLeft,
                pWaistRight,
                [
                  Color.lerp(upperBaseColor, Colors.white, 0.12)!,
                  upperBaseColor,
                  Color.lerp(upperBaseColor, Colors.black, 0.4)!,
                ],
              )
        ..color = isWireframe ? const Color(0x33E4C590) : upperBaseColor
        ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
    );

    // Lengan & Tangan Terpahat Realistis (Realistic Limbs & Sculpted Hands)
    _drawRealisticArmsAndHands(canvas, project, topY, shoulderW, upperBaseColor, upperAccentColor);

    // Detail Khusus Berdasarkan Jenis Busana Atasan
    if (isFacingFront && !isWireframe) {
      final uid = upperBody?.id ?? 'beskap_landhung_solo';

      if (uid.contains('beskap')) {
        // Kerah Shanghai Tegak & Kancing Miring Kanan Khas Beskap
        final collarL = project(-16, topY - 14, 12);
        final collarR = project(16, topY - 14, 12);
        final collarMid = project(0, topY - 10, 16);
        final collarPath = Path()
          ..moveTo(collarL.dx, collarL.dy)
          ..lineTo(collarMid.dx, collarMid.dy)
          ..lineTo(collarR.dx, collarR.dy);
        canvas.drawPath(
          collarPath,
          Paint()
            ..color = upperAccentColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );

        // Kancing Asimetris Emas Menyamping dengan Kilau Spekular
        for (int i = 0; i < 4; i++) {
          final btnPos = project(12.0 - (i * 1.5), topY + 12 + (i * 16), 14);
          canvas.drawCircle(btnPos, 3.4, Paint()..color = const Color(0xFFFFD700));
          canvas.drawCircle(
            Offset(btnPos.dx - 1, btnPos.dy - 1),
            1.2,
            Paint()..color = Colors.white,
          );
        }
      } else if (uid.contains('surjan')) {
        // Enam Kancing Dada Rukun Iman
        for (int i = 0; i < 6; i++) {
          final btnPos = project(0, topY + 8 + (i * 11), 16);
          canvas.drawCircle(btnPos, 2.8, Paint()..color = upperAccentColor);
          canvas.drawCircle(Offset(btnPos.dx - 0.8, btnPos.dy - 0.8), 0.9, Paint()..color = Colors.white);
        }
      } else if (uid.contains('kebaya_kartini')) {
        // Garis Kerah V Panjang Menutup Dada Khas Kebaya Kartini
        final neckMid = project(0, topY + 2, 14);
        final vBottom = project(0, botY - 10, 14);
        canvas.drawLine(
          neckMid,
          vBottom,
          Paint()
            ..color = upperAccentColor
            ..strokeWidth = 2.2,
        );
      } else if (uid.contains('kebaya_kutubaru')) {
        // Bef Persegi di Dada Khas Kebaya Kutubaru
        final befTL = project(-14, topY + 10, 14);
        final befTR = project(14, topY + 10, 14);
        final befBR = project(12, botY - 12, 14);
        final befBL = project(-12, botY - 12, 14);
        final befPath = Path()
          ..moveTo(befTL.dx, befTL.dy)
          ..lineTo(befTR.dx, befTR.dy)
          ..lineTo(befBR.dx, befBR.dy)
          ..lineTo(befBL.dx, befBL.dy)
          ..close();

        canvas.drawPath(
          befPath,
          Paint()..color = const Color(0xFF141210)..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          befPath,
          Paint()..color = upperAccentColor..style = PaintingStyle.stroke..strokeWidth = 1.3,
        );
      }
    }

    // Garis Kontur Atasan
    canvas.drawPath(
      upperPath,
      Paint()
        ..color = const Color(0x66DFB76C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: LENGAN & JARI TANGAN TERPAHAT REALISTIS (SCULPTED HANDS)
  // ---------------------------------------------------------------------------
  void _drawRealisticArmsAndHands(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double topY,
    double shoulderW,
    Color sleeveColor,
    Color trimColor,
  ) {
    final armPaint = Paint()
      ..color = isWireframe ? const Color(0x33E4C590) : sleeveColor
      ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill;

    final trimPaint = Paint()
      ..color = trimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final skinPaint = Paint()
      ..color = isWireframe ? const Color(0x33E4C590) : const Color(0xFFD9B99B);

    // Posisi Pundak, Siku & Pergelangan Kiri
    final leftShoulder = project(-shoulderW, topY, 0);
    final leftElbow = project(
      pose == MannequinPose.sikapSembah ? -32 : -shoulderW - 8,
      pose == MannequinPose.sikapSembah ? -30 : -10,
      pose == MannequinPose.sikapSembah ? 22 : 0,
    );
    final leftWrist = project(
      pose == MannequinPose.sikapSembah ? -8 : -shoulderW - 2,
      pose == MannequinPose.sikapSembah ? -50 : 45,
      pose == MannequinPose.sikapSembah ? 32 : 10,
    );

    final leftArm = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..lineTo(leftElbow.dx, leftElbow.dy)
      ..lineTo(leftWrist.dx, leftWrist.dy);
    canvas.drawPath(leftArm, armPaint..strokeWidth = 16.0..style = PaintingStyle.stroke);
    canvas.drawPath(leftArm, trimPaint);

    // Posisi Pundak, Siku & Pergelangan Kanan
    final rightShoulder = project(shoulderW, topY, 0);
    final rightElbow = project(
      pose == MannequinPose.sikapSembah ? 32 : shoulderW + 8,
      pose == MannequinPose.sikapSembah ? -30 : -10,
      pose == MannequinPose.sikapSembah ? 22 : 0,
    );
    final rightWrist = project(
      pose == MannequinPose.sikapSembah ? 8 : shoulderW + 2,
      pose == MannequinPose.sikapSembah ? -50 : 45,
      pose == MannequinPose.sikapSembah ? 32 : 10,
    );

    final rightArm = Path()
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..lineTo(rightElbow.dx, rightElbow.dy)
      ..lineTo(rightWrist.dx, rightWrist.dy);
    canvas.drawPath(rightArm, armPaint..strokeWidth = 16.0..style = PaintingStyle.stroke);
    canvas.drawPath(rightArm, trimPaint);

    // Anatomi Telapak & Jari Tangan Jawa (Sculpted Hands with Slender Fingers)
    if (!isWireframe) {
      for (final wrist in [leftWrist, rightWrist]) {
        // Telapak Tangan
        canvas.drawCircle(wrist, 5.5 * zoom, skinPaint);

        // 4 Jari Melengkung Santun (Ngapurancang Gesture)
        for (int f = 0; f < 4; f++) {
          final fx = wrist.dx + (f * 1.8 - 2.7);
          final fy = wrist.dy + 6.0 + (f == 1 || f == 2 ? 3.0 : 1.0);
          canvas.drawLine(
            wrist,
            Offset(fx, fy),
            Paint()
              ..color = const Color(0xFFC69468)
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: SABUK CINDE, EPEK & TIMANG EMAS (WAIST ACCESSORIES)
  // ---------------------------------------------------------------------------
  void _drawWaistAccessories(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double Function(double, double, double) getDepth,
  ) {
    const wY = 22.0;
    const wW = 44.0;

    // Sabuk Cinde Merah Lebar
    final pL1 = project(-wW, wY - 8, 4);
    final pR1 = project(wW, wY - 8, 4);
    final pR2 = project(wW, wY + 8, 4);
    final pL2 = project(-wW, wY + 8, 4);

    final cindePath = Path()
      ..moveTo(pL1.dx, pL1.dy)
      ..lineTo(pR1.dx, pR1.dy)
      ..lineTo(pR2.dx, pR2.dy)
      ..lineTo(pL2.dx, pL2.dy)
      ..close();

    canvas.drawPath(
      cindePath,
      Paint()
        ..color = isWireframe ? const Color(0x44E4C590) : const Color(0xFF8B2518)
        ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
    );

    // Epek Hitam di Atas Sabuk Cinde
    final eL1 = project(-wW + 4, wY - 4, 8);
    final eR1 = project(wW - 4, wY - 4, 8);
    final eR2 = project(wW - 4, wY + 4, 8);
    final eL2 = project(-wW + 4, wY + 4, 8);

    final epekPath = Path()
      ..moveTo(eL1.dx, eL1.dy)
      ..lineTo(eR1.dx, eR1.dy)
      ..lineTo(eR2.dx, eR2.dy)
      ..lineTo(eL2.dx, eL2.dy)
      ..close();

    canvas.drawPath(
      epekPath,
      Paint()
        ..color = isWireframe ? Colors.transparent : const Color(0xFF141210)
        ..style = PaintingStyle.fill,
    );

    // Kepala Gesper Timang Emas di Tengah Depan
    final isFacingFront = math.cos(yaw) > -0.1;
    if (isFacingFront && !isWireframe) {
      final timangCenter = project(0, wY, 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: timangCenter, width: 18, height: 14),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFFFD700),
      );
      // Mata permata di tengah timang
      canvas.drawCircle(timangCenter, 2.5, Paint()..color = const Color(0xFF0F5A47));
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: KERIS PUSAKA WARANGKA LADRANG / GAYAMAN
  // ---------------------------------------------------------------------------
  void _drawKerisPusaka(
    Canvas canvas,
    Offset Function(double, double, double) project, {
    required bool isBackView,
  }) {
    if (!accessories.any((a) => a.id.contains('keris'))) return;

    // Keris terselip miring di pinggang belakang kanan (posisi Z negatif)
    const kX = 14.0;
    const kY = 12.0;
    const kZ = -14.0;

    // Jejeran / Gagang Keris
    final handleTop = project(kX + 16, kY - 42, kZ);
    // Daun Warangka Ladrang yang melengkung indah
    final ladrangLeft = project(kX - 16, kY - 14, kZ);
    final ladrangRight = project(kX + 32, kY - 26, kZ);
    // Ujung Pendok Bawah
    final pendokBottom = project(kX - 8, kY + 68, kZ);

    final kerisPath = Path()
      ..moveTo(ladrangLeft.dx, ladrangLeft.dy)
      ..lineTo(ladrangRight.dx, ladrangRight.dy)
      ..lineTo(pendokBottom.dx, pendokBottom.dy)
      ..close();

    final woodPaint = Paint()
      ..color = const Color(0xFF4A3018)
      ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill;
    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(kerisPath, woodPaint);
    canvas.drawPath(kerisPath, goldPaint);

    // Gagang Keris (Deder Ukir)
    canvas.drawLine(
      project(kX + 6, kY - 18, kZ),
      handleTop,
      Paint()
        ..color = const Color(0xFF2C1E12)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: PERHIASAN DADA KALUNG ULUR & BROS RODHA
  // ---------------------------------------------------------------------------
  void _drawChestJewelry(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double breath,
  ) {
    final topNeck = project(0, -68.0 + breath, 16);
    final midBros = project(0, -38.0 + breath, 17);
    final lowBros = project(0, -10.0 + breath, 16);

    final goldPaint = Paint()..color = const Color(0xFFFFD700);

    // Tiga Bros Rodha Permata
    canvas.drawCircle(topNeck, 4.0, goldPaint);
    canvas.drawCircle(midBros, 4.8, goldPaint);
    canvas.drawCircle(lowBros, 3.8, goldPaint);

    // Permata Zamrud di Tengah
    canvas.drawCircle(midBros, 1.8, Paint()..color = const Color(0xFF0F5A47));

    // Kalung Rantai Emas Melengkung
    final chainPath = Path()
      ..moveTo(topNeck.dx - 12, topNeck.dy - 6)
      ..quadraticBezierTo(topNeck.dx, topNeck.dy + 8, topNeck.dx + 12, topNeck.dy - 6);
    canvas.drawPath(
      chainPath,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: KEPALA & PENUTUP KEPALA REALISTIS (BLANGKON / KULUK / SANGGUL)
  // ---------------------------------------------------------------------------
  void _drawHeadwear(
    Canvas canvas,
    Offset Function(double, double, double) project,
    double Function(double, double, double) getDepth,
    double breath,
  ) {
    final headY = -122.0 + breath;
    final headCenter = project(0, headY, 0);

    // 1. Manekin Kepala Terpahat Realistis dengan Shading Gradasi Kulit
    final skinShader = ui.Gradient.radial(
      Offset(headCenter.dx - 4, headCenter.dy - 6),
      22 * zoom,
      [
        const Color(0xFFE8CBB0),
        const Color(0xFFD9B99B),
        const Color(0xFFB08968),
      ],
      [0.0, 0.6, 1.0],
    );

    final headOvalPath = Path()
      ..addOval(Rect.fromCenter(center: headCenter, width: 34 * zoom, height: 46 * zoom));

    canvas.drawPath(
      headOvalPath,
      Paint()
        ..shader = isWireframe ? null : skinShader
        ..color = isWireframe ? const Color(0x33E4C590) : const Color(0xFFD9B99B)
        ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
    );

    // Struktur Wajah Halus: Alis, Garis Hidung & Bibir Santun Javanese Serenity
    final isFacingFront = math.cos(yaw) > -0.2;
    if (isFacingFront && !isWireframe) {
      final noseTip = project(0, headY + 3, 14);
      final noseBridge = project(0, headY - 6, 12);
      canvas.drawLine(
        noseBridge,
        noseTip,
        Paint()
          ..color = const Color(0x66B08968)
          ..strokeWidth = 1.6,
      );

      // Garis Mata Tenang Tertutup (Meditative Calm)
      final eyeL = project(-7, headY - 2, 11);
      final eyeR = project(7, headY - 2, 11);
      canvas.drawLine(Offset(eyeL.dx - 3, eyeL.dy), Offset(eyeL.dx + 3, eyeL.dy), Paint()..color = const Color(0x775A3E26)..strokeWidth = 1.2);
      canvas.drawLine(Offset(eyeR.dx - 3, eyeR.dy), Offset(eyeR.dx + 3, eyeR.dy), Paint()..color = const Color(0x775A3E26)..strokeWidth = 1.2);

      // Garis Bibir
      final mouthCenter = project(0, headY + 12, 12);
      canvas.drawLine(
        Offset(mouthCenter.dx - 4, mouthCenter.dy),
        Offset(mouthCenter.dx + 4, mouthCenter.dy),
        Paint()..color = const Color(0x88945A45)..strokeWidth = 1.5,
      );

      // Telinga Kiri & Kanan Terpahat
      final earL = project(-18, headY + 2, 0);
      final earR = project(18, headY + 2, 0);
      canvas.drawCircle(earL, 4.0 * zoom, Paint()..color = const Color(0xFFC69468));
      canvas.drawCircle(earR, 4.0 * zoom, Paint()..color = const Color(0xFFC69468));
    }

    // 2. Leher Manekin Berotot Santun
    final neckTop = project(0, headY + 20, 0);
    final neckBot = project(0, headY + 38, 0);
    canvas.drawLine(
      neckTop,
      neckBot,
      Paint()
        ..shader = isWireframe
            ? null
            : ui.Gradient.linear(
                neckTop,
                neckBot,
                [const Color(0xFFD9B99B), const Color(0xFFB08968)],
              )
        ..color = const Color(0xFFD9B99B)
        ..strokeWidth = 14.0 * zoom
        ..strokeCap = StrokeCap.round,
    );

    // 3. Mahkota Penutup Kepala (Headwear)
    final hid = headwear?.id ?? 'blangkon_surakarta_parang';
    final hwColor = headwear?.primaryColor ?? const Color(0xFF38271A);
    final hwAccent = headwear?.accentColor ?? const Color(0xFFE4C590);

    if (hid.contains('kuluk')) {
      // Kuluk Kanigaran Silinder Tinggi Emas
      final kTopL = project(-18, headY - 44, 0);
      final kTopR = project(18, headY - 44, 0);
      final kBotR = project(20, headY - 6, 0);
      final kBotL = project(-20, headY - 6, 0);

      final kulukPath = Path()
        ..moveTo(kTopL.dx, kTopL.dy)
        ..lineTo(kTopR.dx, kTopR.dy)
        ..lineTo(kBotR.dx, kBotR.dy)
        ..lineTo(kBotL.dx, kBotL.dy)
        ..close();

      canvas.drawPath(
        kulukPath,
        Paint()
          ..color = isWireframe ? const Color(0x44E4C590) : hwColor
          ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
      );

      // Garis Sulur Prada Emas di Kuluk
      for (double y = headY - 36; y <= headY - 12; y += 10) {
        final gL = project(-18, y, 6);
        final gR = project(18, y, 6);
        canvas.drawLine(gL, gR, Paint()..color = hwAccent..strokeWidth = 1.4);
      }
    } else if (hid.contains('sanggul')) {
      // Sanggul Tekuk Khas Putri dengan Ronce Melati Tiba Dada
      final sanggulBack = project(0, headY + 12, -18);
      canvas.drawCircle(
        sanggulBack,
        15.0 * zoom,
        Paint()..color = const Color(0xFF141210),
      );

      // Ronce Melati Menjuntai ke Dada Kanan
      if (isFacingFront) {
        for (int i = 0; i < 7; i++) {
          final melatiPos = project(14.0 + (i * 0.8), headY + 8 + (i * 12), 12);
          canvas.drawCircle(melatiPos, 3.0, Paint()..color = const Color(0xFFFAF6F0));
        }
      }
    } else {
      // Blangkon Tradisional Realistis (Wiron Lipatan 17 Tingkat Khas Surakarta / Yogyakarta)
      final bTop = project(0, headY - 18, 0);
      final bLeft = project(-22, headY - 4, 0);
      final bRight = project(22, headY - 4, 0);

      final blangkonPath = Path()
        ..moveTo(bLeft.dx, bLeft.dy)
        ..quadraticBezierTo(bTop.dx, bTop.dy - 8, bRight.dx, bRight.dy)
        ..lineTo(bRight.dx, bRight.dy + 12)
        ..quadraticBezierTo(bTop.dx, bTop.dy + 8, bLeft.dx, bLeft.dy + 12)
        ..close();

      canvas.drawPath(
        blangkonPath,
        Paint()
          ..color = isWireframe ? const Color(0x44E4C590) : hwColor
          ..style = isWireframe ? PaintingStyle.stroke : PaintingStyle.fill,
      );

      // Lipatan Wiron Halus Bergaris Emas di Kening Blangkon
      if (!isWireframe && isFacingFront) {
        for (int w = 0; w < 5; w++) {
          final wL = project(-18.0 + (w * 3), headY + 4 - (w * 2.5), 10);
          final wR = project(18.0 - (w * 3), headY + 4 - (w * 2.5), 10);
          canvas.drawLine(wL, wR, Paint()..color = const Color(0x44E4C590)..strokeWidth = 1.0);
        }
      }

      // Jika Blangkon Yogyakarta: Tambahkan Tonjolan Mondholan Bulat di Belakang
      if (hid.contains('yogyakarta')) {
        final mondholanPos = project(0, headY + 8, -20);
        canvas.drawCircle(
          mondholanPos,
          8.5 * zoom,
          Paint()..color = const Color(0xFF1E1610),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: PIN INDIKATOR KATEGORI INTERAKTIF
  // ---------------------------------------------------------------------------
  void _drawCategoryHighlightPin(
    Canvas canvas,
    Offset Function(double, double, double) project,
    ClothingCategory cat,
    double breath,
  ) {
    double pinY = 0.0;
    switch (cat) {
      case ClothingCategory.headwear:
        pinY = -140.0 + breath;
        break;
      case ClothingCategory.upperBody:
        pinY = -35.0 + breath;
        break;
      case ClothingCategory.lowerBody:
        pinY = 110.0;
        break;
      case ClothingCategory.accessories:
        pinY = 22.0;
        break;
    }

    final pinCenter = project(0, pinY, 28);

    // Cincin Pulsasi Cahaya Emas
    final pulseRadius = 14.0 + (math.sin(idleT * math.pi * 2) * 5.0);
    canvas.drawCircle(
      pinCenter,
      pulseRadius,
      Paint()
        ..color = const Color(0x35E4C590)
        ..style = PaintingStyle.fill,
    );

    // Titik Pusat Emas
    canvas.drawCircle(
      pinCenter,
      5.5,
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(
      pinCenter,
      5.5,
      Paint()
        ..color = const Color(0xFF14100D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-RENDERER: ANIMASI 3D BAJU TERBANG DARI GANTUNGAN KE AVATAR
  // ---------------------------------------------------------------------------
  void _draw3DFlyingEquipAnimation(
    Canvas canvas,
    Offset Function(double, double, double) project,
    Size size,
    double cx,
    double cy,
  ) {
    final t = equipProgress.clamp(0.0, 1.0);
    final targetPos = project(0, -35, 15);

    // Lintasan Busur Lengkung 3D Bezier (Arched Trajectory)
    final startPos = equipSourcePos != Offset.zero
        ? equipSourcePos
        : Offset(cx + 120, size.height - 100);

    final controlPoint = Offset(
      (startPos.dx + targetPos.dx) / 2 - 80 * math.sin(t * math.pi),
      math.min(startPos.dy, targetPos.dy) - 140 * math.sin(t * math.pi),
    );

    // Hitung posisi saat ini di kurva kuadratik Bezier
    final curX = (1 - t) * (1 - t) * startPos.dx + 2 * (1 - t) * t * controlPoint.dx + t * t * targetPos.dx;
    final curY = (1 - t) * (1 - t) * startPos.dy + 2 * (1 - t) * t * controlPoint.dy + t * t * targetPos.dy;
    final currentPos = Offset(curX, curY);

    // Skala pembesaran dari ukuran gantungan kecil (scale 0.5) menjadi ukuran avatar penuh (scale 1.0)
    final scale = 0.55 + (0.45 * t);
    // Rotasi dinamis saat melayang
    final rotation = (1 - t) * 0.35 * math.sin(t * math.pi);

    canvas.save();
    canvas.translate(currentPos.dx, currentPos.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    // 1. Aura Cahaya Emas Melingkar (Golden Light Glow)
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        80,
        [
          const Color(0x99FFD700),
          const Color(0x33E4C590),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(Offset.zero, 80, glowPaint);

    // 2. Siluet Baju Terbang Berprada Emas
    final garmentPaint = Paint()
      ..color = animatingGarment?.primaryColor ?? const Color(0xFF2C1E14)
      ..style = PaintingStyle.fill;

    final flyingPath = Path()
      ..moveTo(-45, -35)
      ..lineTo(45, -35)
      ..lineTo(35, 45)
      ..lineTo(-35, 45)
      ..close();

    canvas.drawPath(flyingPath, garmentPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(flyingPath, borderPaint);

    // Kerah & Kancing Baju Terbang
    canvas.drawLine(
      const Offset(-15, -28),
      const Offset(15, -28),
      Paint()..color = const Color(0xFFFFD700)..strokeWidth = 2.5,
    );

    canvas.restore();

    // 3. Pita Partikel Cahaya Emas Mengitari Avatar (Golden Orbit Particles)
    for (int p = 0; p < 8; p++) {
      final pAngle = (t * math.pi * 4) + (p * (math.pi / 4));
      final pDist = 65.0 * (1 - t * 0.5);
      final pX = targetPos.dx + math.cos(pAngle) * pDist;
      final pY = targetPos.dy + math.sin(pAngle) * (pDist * 0.45);

      canvas.drawCircle(
        Offset(pX, pY),
        3.5 * (1 - t * 0.3),
        Paint()..color = const Color(0xFFFFD700),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Wardrobe3DMannequinPainter oldDelegate) =>
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.zoom != zoom ||
      oldDelegate.pan != pan ||
      oldDelegate.isWireframe != isWireframe ||
      oldDelegate.pose != pose ||
      oldDelegate.idleT != idleT ||
      oldDelegate.gender != gender ||
      oldDelegate.headwear != headwear ||
      oldDelegate.upperBody != upperBody ||
      oldDelegate.lowerBody != lowerBody ||
      oldDelegate.accessories != accessories ||
      oldDelegate.highlightedCategory != highlightedCategory ||
      oldDelegate.animatingGarment != animatingGarment ||
      oldDelegate.equipProgress != equipProgress ||
      oldDelegate.equipSourcePos != equipSourcePos;
}
