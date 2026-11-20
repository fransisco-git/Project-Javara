import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/javara_widgets.dart';

/// Kontroller dan Tampilan Sinematik Pembuka JAVARA — Movie-Grade VFX & CGI.
///
/// Urutan Narasi Sinematik:
/// 1. Badai Kosmik (Storm Atmosphere) — Awan temaram bergolak, kilatan petir dalam awan (*sheet lightning*), atmosfer misterius
/// 2. Gatotkaca Melesat — Lengkungan supersonik dari kiri-bawah, kerucut uap Mach (*transonic vapor cone*), semburan ekor plasma emas (*golden jet wash*), dan pendaran partikel kencana
/// 3. Aswatama Menukik — Lengkungan tempur predator dari kanan-atas, jejak asap pusaran gelap (*dark smoke vortex*), percikan petir ungu-legam, dan permata dahi membara
/// 4. Penangguhan Peluru Waktu (Bullet-Time Suspension) — Deselerasi dramatis sesaat sebelum tinju bersentuhan, loncatan busur listrik tegangan tinggi antar-kepalan tangan
/// 5. Benturan Tinju Akbar (CGI Climax Collision) — Kepalan tinju bertemu presisi di titik pusat layar, kilatan horizontal lensa film bioskop (*anamorphic lens flare*), gelombang kejut radial ganda, dan guncangan kamera filmis (*damped camera shake*)
/// 6. Sambaran Petir Fraktal — 16 cabang petir putih-emas meledak ke arah kamera memenuhi layar
/// 7. Penyingkapan Lambang JAVARA — Aliran petir memusat ke tengah membuka lambang asli JAVARA dengan Aksara Jawa `ꦗ ꦮ ꦫ` & aura Surya Mandala
/// 8. Pemuatan Budaya Menuju Halaman Login — Bilah pemuatan bergradasi emas memuat khasanah budaya, lalu bertransisi mulus ke Halaman Login
class JavaraCinematicIntro extends StatefulWidget {
  const JavaraCinematicIntro({
    super.key,
    required this.onComplete,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onRegisterAction,
    this.initialProgress = 0.0,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 7800),
  });

  final VoidCallback onComplete;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final VoidCallback onRegisterAction;
  final double initialProgress;
  final bool autoPlay;
  final Duration duration;

  @override
  State<JavaraCinematicIntro> createState() => JavaraCinematicIntroState();
}

class JavaraCinematicIntroState extends State<JavaraCinematicIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Status teks tahapan pemuatan budaya menuju halaman login
  int _loadingStep = 0;
  static const List<String> _loadingTexts = [
    'Menyelaraskan Khasanah Budaya Jawa...',
    'Memuat Koleksi Busana & Pusaka Adat...',
    'Menyiapkan Gerbang Masuk JAVARA...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.initialProgress,
    );

    _controller.addListener(_handleAnimationProgress);

    if (widget.autoPlay && widget.initialProgress < 1.0) {
      _controller.forward().then((_) {
        if (mounted) {
          widget.onComplete();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat seluruh aset gambar ke GPU memori untuk performa mulus tanpa stutter
    precacheImage(const AssetImage('assets/images/gatotkaca_clash.png'), context);
    precacheImage(const AssetImage('assets/images/aswatama_clash.png'), context);
  }

  void _handleAnimationProgress() {
    final v = _controller.value;
    // Pembaruan teks tahapan pemuatan saat Scene Logo aktif (t: 0.52 s.d 0.88)
    if (v >= 0.52 && v <= 0.88) {
      final sub = ((v - 0.52) / 0.36 * _loadingTexts.length).floor();
      final idx = sub.clamp(0, _loadingTexts.length - 1);
      if (idx != _loadingStep && mounted) {
        setState(() => _loadingStep = idx);
      }
    }
  }

  /// Memutar ulang pengalaman sinematik dari awal
  void replay() {
    HapticFeedback.lightImpact();
    setState(() => _loadingStep = 0);
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  /// Melewati sinematik langsung menuju penyelesaian (ke Login Page)
  void skip() {
    HapticFeedback.selectionClick();
    _controller.stop();
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  /// Kurva pendekatan sinematik: Laju Supersonik -> Bullet-time Slow Motion -> Hentakan Impak
  double _cinematicApproach(double progress) {
    if (progress <= 0.0) return 0.0;
    if (progress >= 1.0) return 1.0;

    // Tahap 1: Percepatan supersonik melesat cepat (0.0 s.d 0.68) -> 88% jarak
    if (progress < 0.68) {
      final p = progress / 0.68;
      return 0.88 * Curves.easeInQuad.transform(p);
    }
    // Tahap 2: Bullet-time Suspension (0.68 s.d 0.88) -> melambat dramatis di udara (88% s.d 93%)
    else if (progress < 0.88) {
      final p = (progress - 0.68) / 0.20;
      return 0.88 + 0.05 * Curves.easeOutSine.transform(p);
    }
    // Tahap 3: Hentakan tumbukan dahsyat (0.88 s.d 1.00) -> melesat cepat mengunci sasaran
    else {
      final p = (progress - 0.88) / 0.12;
      return 0.93 + 0.07 * Curves.easeInCubic.transform(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Titik benturan kepalan tinju tepat di pusat layar
    final collisionCenter = Offset(w * 0.50, h * 0.38);

    // Dimensi gambar ksatria responsif
    final charSize = (w * 0.68).clamp(260.0, 360.0);

    // Titik kepalan tangan terukur dari data piksel aset gambar
    final gatotFistXRel = charSize * 0.864;
    final gatotFistYRel = charSize * 0.371;

    final aswatFistXRel = charSize * 0.217;
    final aswatFistYRel = charSize * 0.613;

    // Posisi target agar kedua kepalan tangan bertemu PERSIS di satu titik koordinat
    final gatotTargetX = collisionCenter.dx - gatotFistXRel;
    final gatotTargetY = collisionCenter.dy - gatotFistYRel;

    final aswatTargetX = collisionCenter.dx - aswatFistXRel;
    final aswatTargetY = collisionCenter.dy - aswatFistYRel;

    // Posisi awal di luar layar
    final gatotStartX = -charSize * 1.45;
    final gatotStartY = h * 0.82;

    final aswatStartX = w + charSize * 0.45;
    final aswatStartY = -charSize * 0.95;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // ==============================================================
        // 1. GUNCANGAN KAMERA FILM (Damped Multi-axis Camera Shake)
        // ==============================================================
        double shakeX = 0.0;
        double shakeY = 0.0;
        if (t >= 0.35 && t <= 0.46) {
          final impactT = (t - 0.35) / 0.11;
          final decay = math.exp(-impactT * 4.6);
          shakeX = math.sin(impactT * math.pi * 14) * 12.0 * decay;
          shakeY = math.cos(impactT * math.pi * 11) * 8.0 * decay;
        }

        // ==============================================================
        // 2. KILATAN ANAMORPHIC LENS FLARE & CONTACT FLASH (t: 0.35 - 0.44)
        // ==============================================================
        double flashOpacity = 0.0;
        double flareIntensity = 0.0;
        if (t >= 0.35 && t <= 0.44) {
          if (t < 0.365) {
            final p = (t - 0.35) / 0.015;
            flashOpacity = p.clamp(0.0, 1.0);
            flareIntensity = p.clamp(0.0, 1.0);
          } else {
            final p = 1.0 - (t - 0.365) / 0.075;
            flashOpacity = p.clamp(0.0, 1.0);
            flareIntensity = (p * 1.3).clamp(0.0, 1.0);
          }
        }

        // ==============================================================
        // 3. DINAMIKA TERBANG & SUDUT KEMIRINGAN AERODINAMIS (t: 0.12 - 0.42)
        // ==============================================================
        double clashProgress = 0.0;
        if (t >= 0.12 && t <= 0.35) {
          clashProgress = _cinematicApproach((t - 0.12) / 0.23);
        } else if (t > 0.35 && t <= 0.40) {
          clashProgress = 1.0; // Freeze frame saat benturan puncak
        }

        // Lengkungan manuver aerodinamis (Parabolic swooping arc)
        final arcOffsetGatot = math.sin(clashProgress * math.pi) * 36.0;
        final gatotCurX = gatotStartX + (gatotTargetX - gatotStartX) * clashProgress;
        final gatotCurY = gatotStartY + (gatotTargetY - gatotStartY) * clashProgress - arcOffsetGatot;
        final gatotAngle = 0.18 - (0.09 * clashProgress);

        final arcOffsetAswat = math.sin(clashProgress * math.pi) * 30.0;
        final aswatCurX = aswatStartX + (aswatTargetX - aswatStartX) * clashProgress;
        final aswatCurY = aswatStartY + (aswatTargetY - aswatStartY) * clashProgress + arcOffsetAswat;
        final aswatAngle = -0.18 + (0.09 * clashProgress);

        final charScale = 0.58 + 0.44 * clashProgress;
        final charOpacity = (t < 0.12 || t > 0.43)
            ? 0.0
            : (t > 0.40 ? (1.0 - (t - 0.40) / 0.03).clamp(0.0, 1.0) : 1.0);

        // Pre-impact micro-arcs (loncatan busur listrik sebelum tinju bersentuhan)
        final isPreImpactSuspension = (t >= 0.29 && t <= 0.35);
        final preImpactT = isPreImpactSuspension ? ((t - 0.29) / 0.06) : 0.0;

        // ==============================================================
        // 4. GELOMBANG KEJUT GANDA & PETIR FRAKTAL (Scene 4 & 5)
        // ==============================================================
        double shockwaveProgress = 0.0;
        if (t >= 0.35 && t <= 0.50) {
          shockwaveProgress = Curves.easeOutCubic.transform((t - 0.35) / 0.15);
        }

        double lightningProgress = 0.0;
        if (t >= 0.35 && t <= 0.53) {
          lightningProgress = ((t - 0.35) / 0.18).clamp(0.0, 1.0);
        }

        // ==============================================================
        // 5. PENYINGKAPAN LAMBANG JAVARA & LOADING (t: 0.48 s.d 1.0)
        // ==============================================================
        double logoOpacity = 0.0;
        double logoScale = 0.90;
        if (t >= 0.48) {
          if (t < 0.54) {
            final sub = (t - 0.48) / 0.06;
            logoOpacity = Curves.easeOut.transform(sub);
            logoScale = 0.90 + 0.10 * sub;
          } else {
            logoOpacity = 1.0;
            logoScale = 1.0;
          }
        }

        // Garis progres loading (t: 0.52 s.d 0.94)
        double loadingProgress = 0.0;
        if (t >= 0.52) {
          loadingProgress = ((t - 0.52) / 0.42).clamp(0.05, 1.0);
        }

        return GestureDetector(
          onTap: skip, // Ketuk di mana saja untuk langsung melompat ke Login Page
          child: Transform.translate(
            offset: Offset(shakeX, shakeY),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ==========================================
                // LAPISAN DASAR: Langit Badai Kosmik Gelap
                // ==========================================
                RepaintBoundary(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF040207),
                          Color(0xFF0C0716),
                          Color(0xFF140C22),
                          Color(0xFF060309),
                        ],
                      ),
                    ),
                  ),
                ),

                // Awan Badai Dinamis & Kilatan Petir Dalam Awan (Sheet Lightning)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CosmicStormCloudsPainter(
                      progress: t,
                      shockwave: shockwaveProgress,
                    ),
                  ),
                ),

                // ==========================================
                // LAPISAN VFX: Ekor Plasma Supersonik & Kerucut Mach
                // ==========================================
                if (charOpacity > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SupersonicFlightVFXPainter(
                        gatotFist: Offset(gatotCurX + gatotFistXRel, gatotCurY + gatotFistYRel),
                        aswatFist: Offset(aswatCurX + aswatFistXRel, aswatCurY + aswatFistYRel),
                        clashProgress: clashProgress,
                      ),
                    ),
                  ),

                // ==========================================
                // LAPISAN KSATRIA: Gatotkaca & Aswatama
                // ==========================================
                if (charOpacity > 0.0) ...[
                  // Gatotkaca Melesat dari Kiri-Bawah
                  Positioned(
                    left: gatotCurX,
                    top: gatotCurY,
                    width: charSize,
                    height: charSize,
                    child: Opacity(
                      opacity: charOpacity,
                      child: Transform.scale(
                        scale: charScale,
                        child: Transform.rotate(
                          angle: gatotAngle,
                          child: Image.asset(
                            'assets/images/gatotkaca_clash.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Aswatama Menukik dari Kanan-Atas
                  Positioned(
                    left: aswatCurX,
                    top: aswatCurY,
                    width: charSize,
                    height: charSize,
                    child: Opacity(
                      opacity: charOpacity,
                      child: Transform.scale(
                        scale: charScale,
                        child: Transform.rotate(
                          angle: aswatAngle,
                          child: Image.asset(
                            'assets/images/aswatama_clash.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Loncatan Busur Listrik Antar-Tinju (Bullet-time Pre-impact Suspension)
                if (isPreImpactSuspension)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PreImpactMicroArcPainter(
                        gatotFist: Offset(gatotCurX + gatotFistXRel, gatotCurY + gatotFistYRel),
                        aswatFist: Offset(aswatCurX + aswatFistXRel, aswatCurY + aswatFistYRel),
                        intensity: preImpactT,
                      ),
                    ),
                  ),

                // ==========================================
                // LAPISAN BENTURAN: Gelombang Kejut & Petir Fraktal
                // ==========================================
                if (shockwaveProgress > 0.0 || lightningProgress > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CollisionClashPainter(
                        centerOffset: collisionCenter,
                        shockwaveProgress: shockwaveProgress,
                        lightningProgress: lightningProgress,
                      ),
                    ),
                  ),

                // Anamorphic Lens Flare (Garis Kilatan Cahaya Horizontal Bioskop)
                if (flareIntensity > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AnamorphicFlarePainter(
                        center: collisionCenter,
                        intensity: flareIntensity,
                      ),
                    ),
                  ),

                // Kilatan Cahaya Putih-Emas (Overexposure Flash)
                if (flashOpacity > 0.0)
                  Positioned.fill(
                    child: Container(
                      color: Color.fromRGBO(255, 252, 238, flashOpacity * 0.92),
                    ),
                  ),

                // ==========================================
                // LAPISAN PENYINGKAPAN LAMBANG ASLI JAVARA & LOADING
                // ==========================================
                if (logoOpacity > 0.0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: logoOpacity,
                      child: Center(
                        child: Transform.scale(
                          scale: logoScale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Lambang Lingkaran Emas Kebesaran dengan Aura Surya Mandala
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDFB76C).withValues(alpha: 0.36),
                                      blurRadius: 42,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const JavaraLogo(size: 190),
                              ),

                              const SizedBox(height: 24),

                              // Aksara Jawa Luhur
                              const Text(
                                'ꦗ ꦮ ꦫ',
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Color(0xFFDFB76C),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'WARISAN BUDAYA JAWA TENGAH',
                                style: JText.serif(
                                  11.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFFEADBCA),
                                ).copyWith(letterSpacing: 3.5),
                              ),

                              const SizedBox(height: 38),

                              // Bilah Pemuatan Budaya Menuju Halaman Login
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 48),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: Text(
                                        _loadingTexts[_loadingStep],
                                        key: ValueKey(_loadingStep),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFDFB76C),
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        height: 3.0,
                                        width: 220,
                                        color: const Color(0x33DFB76C),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: loadingProgress,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF8C5D17),
                                                  Color(0xFFDFB76C),
                                                  Color(0xFFFFF3D1),
                                                  Color(0xFFDFB76C),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Membuka Gerbang JAVARA...',
                                      style: JText.sans(
                                        11,
                                        color: const Color(0x99B8A996),
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ==========================================
                // TOMBOL LEWATI (SKIP BUTTON)
                // ==========================================
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: GestureDetector(
                        onTap: skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x44000000),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0x28FFFFFF),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lewati',
                                style: JText.sans(
                                  12,
                                  weight: FontWeight.w500,
                                  color: const Color(0xCCFFFFFF),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.fast_forward_rounded,
                                size: 14,
                                color: Color(0xCCFFFFFF),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// CUSTOM VFX PAINTERS: Supersonic Trails, Bullet-time Micro-arcs, Anamorphic
// Lens Flare, Radial Shockwave, and Branching Lightning
// ============================================================================

/// Melukis jejak plasma supersonik & partikel energi filmis di belakang ksatria
class _SupersonicFlightVFXPainter extends CustomPainter {
  _SupersonicFlightVFXPainter({
    required this.gatotFist,
    required this.aswatFist,
    required this.clashProgress,
  });

  final Offset gatotFist;
  final Offset aswatFist;
  final double clashProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (clashProgress <= 0.05 || clashProgress >= 0.98) return;

    final alpha = (clashProgress < 0.6)
        ? (clashProgress / 0.6)
        : (1.0 - (clashProgress - 0.6) / 0.4);

    // 1. Ekor Plasma Emas Gatotkaca (Supersonic Golden Jet Wash)
    final gatotTrailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7.0
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFC79B3A).withValues(alpha: alpha * 0.4),
          const Color(0xFFFFE599).withValues(alpha: alpha * 0.85),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(gatotFist.dx - 200, gatotFist.dy + 200),
          gatotFist,
        ),
      );

    final gatotPath = Path();
    gatotPath.moveTo(gatotFist.dx - 240, gatotFist.dy + 240);
    gatotPath.quadraticBezierTo(
      gatotFist.dx - 100,
      gatotFist.dy + 80,
      gatotFist.dx,
      gatotFist.dy,
    );
    canvas.drawPath(gatotPath, gatotTrailPaint);

    // 2. Ekor Asap & Petir Gelap Aswatama (Dark Smoky Plasma Wake)
    final aswatTrailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7.0
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4A1E38).withValues(alpha: alpha * 0.45),
          const Color(0xFF9E4B7A).withValues(alpha: alpha * 0.80),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(aswatFist.dx + 200, aswatFist.dy - 200),
          aswatFist,
        ),
      );

    final aswatPath = Path();
    aswatPath.moveTo(aswatFist.dx + 240, aswatFist.dy - 240);
    aswatPath.quadraticBezierTo(
      aswatFist.dx + 100,
      aswatFist.dy - 80,
      aswatFist.dx,
      aswatFist.dy,
    );
    canvas.drawPath(aswatPath, aswatTrailPaint);
  }

  @override
  bool shouldRepaint(covariant _SupersonicFlightVFXPainter old) =>
      old.gatotFist != gatotFist ||
      old.aswatFist != aswatFist ||
      old.clashProgress != clashProgress;
}

/// Melukis loncatan busur listrik mikro sesaat sebelum benturan tinju (Bullet-time Suspension)
class _PreImpactMicroArcPainter extends CustomPainter {
  _PreImpactMicroArcPainter({
    required this.gatotFist,
    required this.aswatFist,
    required this.intensity,
  });

  final Offset gatotFist;
  final Offset aswatFist;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0.0) return;

    final mid = Offset(
      (gatotFist.dx + aswatFist.dx) / 2,
      (gatotFist.dy + aswatFist.dy) / 2,
    );

    // Pendaran bola plasma terkompresi di antara kedua tinju
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: intensity * 0.95),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.65),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: mid, radius: 50 * intensity));
    canvas.drawCircle(mid, 50 * intensity, glowPaint);

    // 4 busur listrik mikro zig-zag bertegangan tinggi
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Color.fromRGBO(255, 245, 210, intensity);

    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(gatotFist.dx, gatotFist.dy);
      final jitter = (i.isEven ? 9.0 : -9.0) * intensity;
      path.quadraticBezierTo(mid.dx + jitter, mid.dy - jitter, aswatFist.dx, aswatFist.dy);
      canvas.drawPath(path, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PreImpactMicroArcPainter old) =>
      old.gatotFist != gatotFist ||
      old.aswatFist != aswatFist ||
      old.intensity != intensity;
}

/// Melukis Anamorphic Lens Flare (Garis Kilatan Cahaya Horizontal Sinematik Film)
class _AnamorphicFlarePainter extends CustomPainter {
  _AnamorphicFlarePainter({
    required this.center,
    required this.intensity,
  });

  final Offset center;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0.0) return;

    final cy = center.dy;
    final w = size.width;

    // Garis sorot horizontal panjang membentang selebar layar (Anamorphic Cinema Flare)
    final flarePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF9ED5FF).withValues(alpha: intensity * 0.40),
          const Color(0xFFFFFFFF).withValues(alpha: intensity * 0.98),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.40),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, cy - 3.5, w, 7.0));

    canvas.drawRect(Rect.fromLTWH(0, cy - 2.0, w, 4.0), flarePaint);

    // Inti pendaran vertikal lembut
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: intensity),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 110 * intensity));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 240 * intensity, height: 32 * intensity),
      coreGlowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnamorphicFlarePainter old) =>
      old.center != center || old.intensity != intensity;
}

/// Melukis lapisan awan badai misterius dan dorongan awan saat benturan
class _CosmicStormCloudsPainter extends CustomPainter {
  _CosmicStormCloudsPainter({
    required this.progress,
    required this.shockwave,
  });

  final double progress;
  final double shockwave;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final drift = (progress * 35.0) % w;

    final cloudPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45)
      ..style = PaintingStyle.fill;

    final push = shockwave * 75.0;

    // Gumpalan awan atas
    cloudPaint.color = const Color(0x441E1430);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.30 + drift * 0.5 - push, h * 0.16 - push * 0.5),
        width: w * 0.95,
        height: h * 0.26,
      ),
      cloudPaint,
    );

    cloudPaint.color = const Color(0x382C1B42);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.75 - drift * 0.3 + push, h * 0.24 - push * 0.5),
        width: w * 0.88,
        height: h * 0.22,
      ),
      cloudPaint,
    );

    // Gumpalan awan bawah
    cloudPaint.color = const Color(0x55110D1A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50 + push, h * 0.85 + push),
        width: w * 1.25,
        height: h * 0.32,
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CosmicStormCloudsPainter old) =>
      old.progress != progress || old.shockwave != shockwave;
}

/// Melukis Gelombang Kejut Radial dan Petir Bercabang dari Titik Benturan Tinju
class _CollisionClashPainter extends CustomPainter {
  _CollisionClashPainter({
    required this.centerOffset,
    required this.shockwaveProgress,
    required this.lightningProgress,
  });

  final Offset centerOffset;
  final double shockwaveProgress;
  final double lightningProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Pendaran Inti Benturan (Radiant Core Glow)
    if (shockwaveProgress > 0.0 && shockwaveProgress < 0.75) {
      final coreAlpha = (1.0 - shockwaveProgress / 0.75).clamp(0.0, 1.0);
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: coreAlpha),
            const Color(0xFFFFDF9E).withValues(alpha: coreAlpha * 0.75),
            const Color(0xFFC79B3A).withValues(alpha: coreAlpha * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.52, 1.0],
        ).createShader(
          Rect.fromCircle(center: centerOffset, radius: 130 * (0.3 + shockwaveProgress)),
        );
      canvas.drawCircle(centerOffset, 130 * (0.3 + shockwaveProgress), corePaint);
    }

    // 2. Cincin Gelombang Kejut Radial (Expanding Shockwave Ring)
    if (shockwaveProgress > 0.0) {
      final ringRadius = size.width * 1.25 * shockwaveProgress;
      final ringAlpha = (1.0 - shockwaveProgress).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (14.0 * (1.0 - shockwaveProgress)).clamp(1.2, 14.0)
        ..color = const Color(0xFFFFEAB8).withValues(alpha: ringAlpha * 0.85);

      canvas.drawCircle(centerOffset, ringRadius, ringPaint);

      final outerRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFFC79B3A).withValues(alpha: ringAlpha * 0.45);

      canvas.drawCircle(centerOffset, ringRadius * 0.86, outerRingPaint);
    }

    // 3. Petir Fraktal Bercabang Menyambar ke Kamera (Branching Lightning Arcs)
    if (lightningProgress > 0.0) {
      final alpha = (lightningProgress < 0.55)
          ? (lightningProgress / 0.55)
          : (1.0 - (lightningProgress - 0.55) / 0.45);

      final boltGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFDFB76C).withValues(alpha: alpha * 0.70);

      final boltCorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.98);

      const int branchCount = 14;
      final maxReach = size.width * 0.98 * lightningProgress;

      for (int i = 0; i < branchCount; i++) {
        final baseAngle = (i * 2 * math.pi / branchCount) + 0.12;
        final path = Path();
        path.moveTo(centerOffset.dx, centerOffset.dy);

        double curX = centerOffset.dx;
        double curY = centerOffset.dy;
        const int steps = 5;
        final stepDist = maxReach / steps;

        for (int s = 1; s <= steps; s++) {
          final jitterAngle = baseAngle + math.sin(i * 3.0 + s * 4.5) * 0.32;
          final targetX = curX + math.cos(jitterAngle) * stepDist;
          final targetY = curY + math.sin(jitterAngle) * stepDist;
          path.lineTo(targetX, targetY);
          curX = targetX;
          curY = targetY;

          // Cabang samping (Sub-branches)
          if (s == 2 || s == 3) {
            final subPath = Path();
            subPath.moveTo(curX, curY);
            final subAngle = jitterAngle + (i.isEven ? 0.55 : -0.55);
            subPath.lineTo(
              curX + math.cos(subAngle) * stepDist * 0.55,
              curY + math.sin(subAngle) * stepDist * 0.55,
            );
            canvas.drawPath(subPath, boltGlowPaint);
            canvas.drawPath(subPath, boltCorePaint);
          }
        }

        canvas.drawPath(path, boltGlowPaint);
        canvas.drawPath(path, boltCorePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CollisionClashPainter old) =>
      old.shockwaveProgress != shockwaveProgress ||
      old.lightningProgress != lightningProgress;
}
