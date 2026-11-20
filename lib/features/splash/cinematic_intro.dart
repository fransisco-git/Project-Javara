import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/javara_widgets.dart';

/// Kontroller dan Tampilan Sinematik Pembuka JAVARA — Blockbuster CGI / VFX Experience.
///
/// Urutan Narasi 9 Adegan Sinematik Epik:
/// 1. Badai Kosmik (Storm Atmosphere) — Awan temaram bergolak, kilatan petir jauh, misteri mendalam
/// 2. Gatotkaca — Melesat dari kiri-bawah dengan lengkungan terbang aerodinamis, ekor plasma emas (*sonic boom wake*), dan partikel energi kencana
/// 3. Aswatama — Menukik dari kanan-atas dengan lintasan predator ganas, jejak asap petir legam-ungu (*dark lightning & smoke trail*), dan percikan bara logam
/// 4. Benturan Akbar (CGI Climax Collision) — Garis kecepatan (*speed lines*), penangguhan peluru waktu (*bullet-time suspension*), loncatan busur listrik antar-tinju, benturan tepat di pusat layar, kilatan horizontal (*anamorphic lens flare*), gelombang kejut ganda, dan guncangan kamera teredam (*damped camera shake*)
/// 5. Sambaran Petir Fraktal — Percabangan petir putih-emas meledak ke arah lensa kamera memenuhi layar
/// 6. Penyingkapan Lambang JAVARA — Menyatukan energi petir ke pusat, menyingkap lambang kebesaran asli JAVARA dengan aura mandala emas & bilah pemuatan budaya
/// 7. Transisi Halimun Dataran Tinggi Dieng — Peleburan badai ke lanskap senja pegunungan Dieng, siluet Gunung Sindoro, dan kilatan petir halus di awan senja
/// 8. Pembukaan Gerbang Candi Bentar — Dari tertutup rapat di tengah, kedua pilar batu andesit perlahan membuka ke kiri & kanan dengan kelembaman batu masif dan perspektif 3D
/// 9. Penyingkapan Antarmuka Selamat Datang Editorial — Tipografi minimalis, lanskap dominan, tombol aksi emas antik, dan tombol putar ulang
class JavaraCinematicIntro extends StatefulWidget {
  const JavaraCinematicIntro({
    super.key,
    required this.onComplete,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onRegisterAction,
    this.initialProgress = 0.0,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 9200),
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

  // Status teks pemuatan budaya untuk Scene 6 (Lambang JAVARA)
  int _loadingStep = 0;
  static const List<String> _loadingTexts = [
    'Menyelaraskan Khasanah Budaya Jawa...',
    'Memuat Pusaka Luhur Jawa Tengah...',
    'Menghubungkan Warisan Lintas Generasi...',
    'Khasanah Jawa Siap Dijelajahi',
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
    // Pra-muat seluruh aset gambar ke GPU memori untuk performa mulus 60fps
    precacheImage(const AssetImage('assets/images/gatotkaca_clash.png'), context);
    precacheImage(const AssetImage('assets/images/aswatama_clash.png'), context);
    precacheImage(const AssetImage('assets/images/dieng_sunset_reflection.jpg'), context);
    precacheImage(const AssetImage('assets/images/dieng_sunset.jpg'), context);
    precacheImage(const AssetImage('assets/images/temple_gate_left.png'), context);
    precacheImage(const AssetImage('assets/images/temple_gate_right.png'), context);
  }

  void _handleAnimationProgress() {
    final v = _controller.value;
    // Pembaruan teks tahapan pemuatan saat Scene 6 aktif (t: 0.50 s.d 0.66)
    if (v >= 0.50 && v <= 0.66) {
      final sub = ((v - 0.50) / 0.16 * _loadingTexts.length).floor();
      final idx = sub.clamp(0, _loadingTexts.length - 1);
      if (idx != _loadingStep && mounted) {
        setState(() => _loadingStep = idx);
      }
    }
  }

  /// Memutar ulang pengalaman sinematik dari detik pertama
  void replay() {
    HapticFeedback.lightImpact();
    setState(() => _loadingStep = 0);
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  /// Melewati sinematik langsung menuju gerbang terbuka & antarmuka selamat datang
  void skip() {
    HapticFeedback.selectionClick();
    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ).then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  /// Kurva pendekatan sinematik filmis: Laju Supersonik -> Penangguhan Peluru Waktu -> Hentakan Puncak
  double _cinematicApproach(double progress) {
    if (progress <= 0.0) return 0.0;
    if (progress >= 1.0) return 1.0;

    // Tahap 1: Laju supersonik melesat cepat (0.0 s.d 0.70) -> 88% jarak
    if (progress < 0.70) {
      final p = progress / 0.70;
      return 0.88 * Curves.easeInQuad.transform(p);
    }
    // Tahap 2: Bullet-time Suspension (0.70 s.d 0.90) -> melambat dramatis di udara (88% s.d 93%)
    else if (progress < 0.90) {
      final p = (progress - 0.70) / 0.20;
      return 0.88 + 0.05 * Curves.easeOutSine.transform(p);
    }
    // Tahap 3: Hentakan tumbukan dahsyat (0.90 s.d 1.00) -> melesat cepat ke 100%
    else {
      final p = (progress - 0.90) / 0.10;
      return 0.93 + 0.07 * Curves.easeInCubic.transform(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Titik benturan kepalan tinju di pusat layar
    final collisionCenter = Offset(w * 0.50, h * 0.38);

    // Dimensi gambar ksatria proporsional
    final charSize = (w * 0.65).clamp(250.0, 340.0);

    // Titik kepalan tangan terukur dari data piksel aset gambar
    final gatotFistXRel = charSize * 0.864;
    final gatotFistYRel = charSize * 0.371;

    final aswatFistXRel = charSize * 0.217;
    final aswatFistYRel = charSize * 0.613;

    // Posisi target agar kepalan tangan bertemu PERSIS di satu titik
    final gatotTargetX = collisionCenter.dx - gatotFistXRel;
    final gatotTargetY = collisionCenter.dy - gatotFistYRel;

    final aswatTargetX = collisionCenter.dx - aswatFistXRel;
    final aswatTargetY = collisionCenter.dy - aswatFistYRel;

    // Posisi awal di luar layar
    final gatotStartX = -charSize * 1.40;
    final gatotStartY = h * 0.80;

    final aswatStartX = w + charSize * 0.40;
    final aswatStartY = -charSize * 0.90;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // ==============================================================
        // 1. GUNCANGAN KAMERA FILM (Damped Multi-axis Camera Shake)
        // ==============================================================
        double shakeX = 0.0;
        double shakeY = 0.0;
        if (t >= 0.36 && t <= 0.46) {
          final impactT = (t - 0.36) / 0.10;
          final decay = math.exp(-impactT * 4.5);
          shakeX = math.sin(impactT * math.pi * 12) * 11.0 * decay;
          shakeY = math.cos(impactT * math.pi * 10) * 7.0 * decay;
        }

        // ==============================================================
        // 2. KILATAN PUTIH-EMAS & ANAMORPHIC LENS FLARE (t: 0.36 - 0.44)
        // ==============================================================
        double flashOpacity = 0.0;
        double flareIntensity = 0.0;
        if (t >= 0.36 && t <= 0.44) {
          if (t < 0.375) {
            final p = (t - 0.36) / 0.015;
            flashOpacity = p.clamp(0.0, 1.0);
            flareIntensity = p.clamp(0.0, 1.0);
          } else {
            final p = 1.0 - (t - 0.375) / 0.065;
            flashOpacity = p.clamp(0.0, 1.0);
            flareIntensity = (p * 1.2).clamp(0.0, 1.0);
          }
        }

        // ==============================================================
        // 3. DINAMIKA TERBANG & SUDUT KEMIRINGAN AERODINAMIS
        // ==============================================================
        double clashProgress = 0.0;
        if (t >= 0.12 && t <= 0.36) {
          clashProgress = _cinematicApproach((t - 0.12) / 0.24);
        } else if (t > 0.36 && t <= 0.42) {
          clashProgress = 1.0; // Freeze frame saat benturan puncak
        }

        // Lengkungan terbang aerodinamis (Parabolic swooping arc)
        final arcOffsetGatot = math.sin(clashProgress * math.pi) * 35.0;
        final gatotCurX = gatotStartX + (gatotTargetX - gatotStartX) * clashProgress;
        final gatotCurY = gatotStartY + (gatotTargetY - gatotStartY) * clashProgress - arcOffsetGatot;
        final gatotAngle = 0.16 - (0.08 * clashProgress); // Kemiringan menyusut saat mendekati benturan

        final arcOffsetAswat = math.sin(clashProgress * math.pi) * 28.0;
        final aswatCurX = aswatStartX + (aswatTargetX - aswatStartX) * clashProgress;
        final aswatCurY = aswatStartY + (aswatTargetY - aswatStartY) * clashProgress + arcOffsetAswat;
        final aswatAngle = -0.16 + (0.08 * clashProgress);

        final charScale = 0.60 + 0.40 * clashProgress;
        final charOpacity = (t < 0.12 || t > 0.44)
            ? 0.0
            : (t > 0.41 ? (1.0 - (t - 0.41) / 0.03).clamp(0.0, 1.0) : 1.0);

        // Pre-impact micro-arcs (loncatan busur listrik sesaat sebelum tinju bersentuhan)
        final isPreImpactSuspension = (t >= 0.30 && t <= 0.36);
        final preImpactT = isPreImpactSuspension ? ((t - 0.30) / 0.06) : 0.0;

        // ==============================================================
        // 4. GELOMBANG KEJUT GANDA & PETIR FRAKTAL (Scene 4 & 5)
        // ==============================================================
        double shockwaveProgress = 0.0;
        if (t >= 0.36 && t <= 0.50) {
          shockwaveProgress = Curves.easeOutCubic.transform((t - 0.36) / 0.14);
        }

        double lightningProgress = 0.0;
        if (t >= 0.36 && t <= 0.54) {
          lightningProgress = ((t - 0.36) / 0.18).clamp(0.0, 1.0);
        }

        // ==============================================================
        // 5. PENYINGKAPAN LAMBANG JAVARA (Scene 6) (t: 0.48 s.d 0.68)
        // ==============================================================
        double logoOpacity = 0.0;
        double logoScale = 0.92;
        if (t >= 0.48 && t <= 0.68) {
          if (t < 0.53) {
            final sub = (t - 0.48) / 0.05;
            logoOpacity = Curves.easeOut.transform(sub);
            logoScale = 0.90 + 0.10 * sub;
          } else if (t <= 0.64) {
            logoOpacity = 1.0;
            logoScale = 1.0;
          } else {
            final sub = (t - 0.64) / 0.04;
            logoOpacity = (1.0 - sub).clamp(0.0, 1.0);
            logoScale = 1.0 + 0.04 * sub;
          }
        }

        // ==============================================================
        // 6. PELEBURAN KE LANSKAP SENJA DIENG (Scene 7) (t: 0.62 s.d 1.0)
        // ==============================================================
        double diengOpacity = 0.0;
        if (t >= 0.62) {
          diengOpacity = Curves.easeInOutCubic.transform(((t - 0.62) / 0.14).clamp(0.0, 1.0));
        }

        // ==============================================================
        // 7. PEMBUKAAN GERBANG CANDI BENTAR (Scene 8) (t: 0.72 s.d 0.90)
        // ==============================================================
        double gateOpenProgress = 0.0;
        if (t >= 0.72) {
          final raw = ((t - 0.72) / 0.18).clamp(0.0, 1.0);
          gateOpenProgress = Curves.easeInOutCubic.transform(raw);
        }
        // Jarak geser sayap candi bentar ke kiri dan kanan dari keadaan tertutup rapat
        final gateShift = (w * 0.42) * gateOpenProgress;

        // ==============================================================
        // 8. PENYINGKAPAN ANTARMUKA SELAMAT DATANG (Scene 9) (t: 0.86 s.d 1.0)
        // ==============================================================
        double uiOpacity = 0.0;
        double uiSlide = 22.0;
        if (t >= 0.86) {
          final raw = ((t - 0.86) / 0.14).clamp(0.0, 1.0);
          uiOpacity = Curves.easeOutCubic.transform(raw);
          uiSlide = 22.0 * (1.0 - uiOpacity);
        }

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==========================================
              // LAPISAN DASAR: Langit Badai Kosmik Gelap (Scene 1-6)
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
                        Color(0xFF120B20),
                        Color(0xFF060309),
                      ],
                    ),
                  ),
                ),
              ),

              // Awan Badai Dinamis & Dorongan Gelombang Kejut
              if (t < 0.72)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StormCloudsPainter(
                      progress: t,
                      shockwave: shockwaveProgress,
                    ),
                  ),
                ),

              // ==========================================
              // LAPISAN LANSKAP SENJA CANDI DIENG (Scene 7-9)
              // ==========================================
              if (diengOpacity > 0.0)
                Positioned.fill(
                  child: Opacity(
                    opacity: diengOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Foto Lanskap Gunung Sindoro & Senja Dieng dengan Pantulan Air Sempurna
                        RepaintBoundary(
                          child: Image.asset(
                            'assets/images/dieng_sunset_reflection.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/dieng_sunset.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),

                        // Gradasi Senja Alami Dieng (Muted Amber, Dusty Rose, Slate Mist)
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66140D20), // Langit malam violet dingin
                                Colors.transparent,
                                Color(0x28B8736B), // Pendaran amber senja
                                Color(0xE60A0710), // Dasar andesit gelap untuk keterbacaan UI
                              ],
                              stops: [0.0, 0.30, 0.65, 1.0],
                            ),
                          ),
                        ),

                        // Petir Lembut Halus di Balik Awan Senja Pegunungan (Sesuai Permintaan)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DistantCloudLightningPainter(
                              time: t * 5.0,
                            ),
                          ),
                        ),

                        // Halimun Dingin Pegunungan Berlapis (Parallax Mist System)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DiengMultiLayerMistPainter(
                              time: t * 4.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ==========================================
              // LAPISAN VFX: Ekor Plasma Supersonik & Garis Kecepatan
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
              // LAPISAN KSATRIA: Gatotkaca & Aswatama (Scene 2-4)
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

              // Loncatan Busur Listrik Antar-Tinju (Pre-impact Bullet-Time Suspension)
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
              // LAPISAN BENTURAN: Gelombang Kejut & Petir Fraktal (Scene 4-5)
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

              // Anamorphic Lens Flare (Kilatan Cahaya Horizontal Film Bioskop)
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
                    color: Color.fromRGBO(255, 252, 238, flashOpacity * 0.90),
                  ),
                ),

              // ==========================================
              // LAPISAN LAMBANG ASLI JAVARA (Scene 6)
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
                            // Lambang Lingkaran Emas Kebesaran
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDFB76C).withValues(alpha: 0.32),
                                    blurRadius: 36,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: const JavaraLogo(size: 185),
                            ),

                            const SizedBox(height: 22),

                            // Aksara Jawa Luhur
                            const Text(
                              'ꦗ ꦮ ꦫ',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFFDFB76C),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'WARISAN BUDAYA JAWA TENGAH',
                              style: JText.serif(
                                11,
                                weight: FontWeight.w700,
                                color: const Color(0xFFEADBCA),
                              ).copyWith(letterSpacing: 3.5),
                            ),

                            const SizedBox(height: 34),

                            // Bilah Pemuatan Budaya Terintegrasi Alami
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
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDFB76C),
                                        letterSpacing: 0.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      height: 2.5,
                                      width: 200,
                                      color: const Color(0x33DFB76C),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: ((t - 0.48) / 0.18).clamp(0.1, 1.0),
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
              // LAPISAN GERBANG CANDI BENTAR (Scene 8)
              // (Membuka dari Tertutup Rapat di Tengah ke Kiri & Kanan)
              // ==========================================
              if (diengOpacity > 0.0) ...[
                // Sayap Kiri Candi Bentar (Membuka ke Arah Kiri)
                Positioned(
                  left: -gateShift,
                  top: h * 0.12,
                  bottom: -15,
                  width: w * 0.52,
                  child: Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.14 * gateOpenProgress),
                    child: Image.asset(
                      'assets/images/temple_gate_left.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Sayap Kanan Candi Bentar (Membuka ke Arah Kanan)
                Positioned(
                  right: -gateShift,
                  top: h * 0.12,
                  bottom: -15,
                  width: w * 0.52,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(0.14 * gateOpenProgress),
                    child: Image.asset(
                      'assets/images/temple_gate_right.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
                ),

                // Ambang Lantai Batu Andesit (Grounded Threshold)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 32,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFF09060D),
                          Color(0x990E0914),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // ==========================================
              // LAPISAN ANTARMUKA SELAMAT DATANG (Scene 9)
              // ==========================================
              if (uiOpacity > 0.0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: uiOpacity,
                    child: Transform.translate(
                      offset: Offset(0, uiSlide),
                      child: SafeArea(
                        top: false,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Judul Utama (Headline Editorial Adiluhung)
                                  Text(
                                    'Mengenal warisan.\nMemahami makna.',
                                    style: JText.editorial(
                                      34,
                                      weight: FontWeight.w700,
                                      color: JColors.warmIvory,
                                      height: 1.16,
                                      letterSpacing: 0.4,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),

                                  const SizedBox(height: 10),

                                  // Deskripsi Filosofis JAVARA
                                  Text(
                                    'Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi.',
                                    style: JText.serif(
                                      14,
                                      color: const Color(0xFFD6CBC0),
                                      height: 1.5,
                                      weight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),

                                  const SizedBox(height: 24),

                                  // Tombol Utama: Mulai Eksplorasi Budaya →
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFC79B3A), // Emas Antik Murni
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x33000000),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: widget.onPrimaryAction,
                                        child: Center(
                                          child: Text(
                                            'Mulai Eksplorasi Budaya →',
                                            style: JText.sans(
                                              15,
                                              weight: FontWeight.w700,
                                              color: const Color(0xFF1E160D),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Tombol Sekunder: Masuk ke Akun Anda
                                  Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0x1AFFFFFF),
                                      border: Border.all(
                                        color: const Color(0x33DFB76C),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: widget.onSecondaryAction,
                                        child: Center(
                                          child: Text(
                                            'Masuk ke Akun Anda',
                                            style: JText.sans(
                                              14,
                                              weight: FontWeight.w600,
                                              color: const Color(0xFFF2E7D7),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Tautan Registrasi
                                  GestureDetector(
                                    onTap: widget.onRegisterAction,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            style: JText.sans(
                                              13,
                                              color: const Color(0xFFAFA292),
                                            ),
                                            children: const [
                                              TextSpan(text: 'Belum memiliki akun? '),
                                              TextSpan(
                                                text: 'Daftar di sini',
                                                style: TextStyle(
                                                  color: Color(0xFFDFB76C),
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Color(0xFFDFB76C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ==========================================
              // KONTROL NAVIGASI ATAS: Lewati / Putar Ulang
              // ==========================================
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Putar Ulang Sinematik (Aktif saat UI Welcome tampil)
                        if (t >= 0.86)
                          GestureDetector(
                            onTap: replay,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0x44100C16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x33DFB76C),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.replay_rounded,
                                    size: 13,
                                    color: Color(0xFFDFB76C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Putar Ulang',
                                    style: JText.sans(
                                      11.5,
                                      weight: FontWeight.w500,
                                      color: const Color(0xFFEADBCA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Tombol Lewati Sinematik (Saat animasi sedang berjalan)
                        if (t < 0.86)
                          GestureDetector(
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
                          )
                        else
                          const SizedBox.shrink(),
                      ],
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
}

// ============================================================================
// CUSTOM VFX PAINTERS: Plasma Trails, Bullet-time Micro-arcs, Lens Flare,
// Distant Lightning, Shockwaves, and Parallax Mist
// ============================================================================

/// Melukis jejak plasma supersonik & garis kecepatan filmis di belakang ksatria
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
      ..strokeWidth = 6.0
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFC79B3A).withValues(alpha: alpha * 0.4),
          const Color(0xFFFFE599).withValues(alpha: alpha * 0.8),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(gatotFist.dx - 180, gatotFist.dy + 180),
          gatotFist,
        ),
      );

    final gatotPath = Path();
    gatotPath.moveTo(gatotFist.dx - 220, gatotFist.dy + 220);
    gatotPath.quadraticBezierTo(
      gatotFist.dx - 90,
      gatotFist.dy + 70,
      gatotFist.dx,
      gatotFist.dy,
    );
    canvas.drawPath(gatotPath, gatotTrailPaint);

    // 2. Ekor Asap & Petir Gelap Aswatama (Dark Smoky Plasma Wake)
    final aswatTrailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4A1E38).withValues(alpha: alpha * 0.4),
          const Color(0xFF9E4B7A).withValues(alpha: alpha * 0.75),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(aswatFist.dx + 180, aswatFist.dy - 180),
          aswatFist,
        ),
      );

    final aswatPath = Path();
    aswatPath.moveTo(aswatFist.dx + 220, aswatFist.dy - 220);
    aswatPath.quadraticBezierTo(
      aswatFist.dx + 90,
      aswatFist.dy - 70,
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
          const Color(0xFFFFFFFF).withValues(alpha: intensity * 0.9),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: mid, radius: 45 * intensity));
    canvas.drawCircle(mid, 45 * intensity, glowPaint);

    // 4 busur listrik mikro zig-zag bertegangan tinggi
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = Color.fromRGBO(255, 245, 210, intensity);

    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(gatotFist.dx, gatotFist.dy);
      final jitter = (i.isEven ? 8.0 : -8.0) * intensity;
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

    // Garis sorot horizontal panjang membentang selebar layar
    final flarePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF9ED5FF).withValues(alpha: intensity * 0.35),
          const Color(0xFFFFFFFF).withValues(alpha: intensity * 0.95),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, cy - 3, w, 6));

    canvas.drawRect(Rect.fromLTWH(0, cy - 1.5, w, 3.0), flarePaint);

    // Inti pendaran vertikal lembut
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: intensity),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 100 * intensity));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 220 * intensity, height: 28 * intensity),
      coreGlowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnamorphicFlarePainter old) =>
      old.center != center || old.intensity != intensity;
}

/// Melukis lapisan awan badai misterius dan dorongan awan saat benturan
class _StormCloudsPainter extends CustomPainter {
  _StormCloudsPainter({
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
  bool shouldRepaint(covariant _StormCloudsPainter old) =>
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
      final ringRadius = size.width * 1.20 * shockwaveProgress;
      final ringAlpha = (1.0 - shockwaveProgress).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (14.0 * (1.0 - shockwaveProgress)).clamp(1.2, 14.0)
        ..color = const Color(0xFFFFEAB8).withValues(alpha: ringAlpha * 0.80);

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
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFDFB76C).withValues(alpha: alpha * 0.65);

      final boltCorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.95);

      const int branchCount = 12;
      final maxReach = size.width * 0.95 * lightningProgress;

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

/// Melukis kilatan petir lembut alami di balik awan senja Dieng
class _DistantCloudLightningPainter extends CustomPainter {
  _DistantCloudLightningPainter({required this.time});
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    // Kilatan terjadi berkala secara lembut
    final cycle = (time * 0.6) % (math.pi * 2);
    final intensity = (math.sin(cycle) > 0.85)
        ? ((math.sin(cycle) - 0.85) / 0.15) * 0.28
        : 0.0;

    if (intensity <= 0.0) return;

    final w = size.width;
    final h = size.height;

    final flashPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
      ..color = const Color(0xFFFFEFB8).withValues(alpha: intensity);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.35),
        width: w * 0.75,
        height: 120,
      ),
      flashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DistantCloudLightningPainter old) => old.time != time;
}

/// Melukis kabut dingin pegunungan Dieng multi-lapis (Parallax Mist System)
class _DiengMultiLayerMistPainter extends CustomPainter {
  _DiengMultiLayerMistPainter({required this.time});
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mistPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48)
      ..style = PaintingStyle.fill;

    // Lapisan 1: Halimun dalam (lambat)
    final offset1 = math.sin(time * 0.35) * 25.0;
    mistPaint.color = const Color(0x2B4A5868);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.45 + offset1, h * 0.68),
        width: w * 1.35,
        height: 110,
      ),
      mistPaint,
    );

    // Lapisan 2: Kabut tengah (sedang)
    final offset2 = math.cos(time * 0.50) * 32.0;
    mistPaint.color = const Color(0x3368788C);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55 + offset2, h * 0.78),
        width: w * 1.45,
        height: 130,
      ),
      mistPaint,
    );

    // Lapisan 3: Halimun dasar dekat lantai candi (merayap lembut)
    final offset3 = math.sin(time * 0.65) * 18.0;
    mistPaint.color = const Color(0x228E9CAE);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50 + offset3, h * 0.88),
        width: w * 1.50,
        height: 120,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiengMultiLayerMistPainter old) => old.time != time;
}
