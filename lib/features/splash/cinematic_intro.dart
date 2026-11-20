import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/javara_widgets.dart';

/// Kontroller dan Tampilan Sinematik Pembuka JAVARA — Movie-Grade VFX & CGI.
///
/// Urutan Narasi Sinematik (Terinspirasi Adegan Benturan Hulkbuster vs Hulk):
/// 1. Badai Kosmik (Storm Atmosphere) [t: 0.00 - 0.08] — Awan bergolak, kilatan petir dalam awan (*sheet lightning*).
/// 2. Pendekatan Horisontal (Horizontal Standoff Approach) [t: 0.08 - 0.20] — Gatotkaca dari kiri, Aswatama dari kanan melesat pada bidang tempur horisontal yang sejajar sempurna.
/// 3. Tarikan Pukulan & Pengumpulan Daya (Anticipation Wind-Up) [t: 0.20 - 0.28] — Kedua ksatria menarik kepalan tinju dan torso ke belakang, busur listrik tegangan tinggi berderak di antara kedua tinju.
/// 4. Lontaran Pukulan Lurus Berkecepatan Penuh (Explosive Straight Punch Thrust) [t: 0.28 - 0.335] — Melesat eksplosif ke arah tengah dengan kerucut uap Mach dan ekor plasma supersonik.
/// 5. Benturan Buku-Jari ke Buku-Jari & Freeze Frame (Knuckle-to-Knuckle Hit-Stop) [t: 0.335 - 0.365] — Kedua kepalan tangan bertemu tepat buku-jari ke buku-jari di titik tengah layar (0px offset). Aksi membeku sesaat (Hit-stop).
/// 6. Ledakan Efek VFX Bioskop (Impact Burst & Planar Shockwave) [t: 0.335 - 0.44] — Kilatan horizontal lensa film bioskop (*35mm anamorphic lens flare*), lembaran gelombang kejut vertikal lonjong, 36+ partikel percikan kinetik, dan guncangan kamera teredam (*damped camera shake*).
/// 7. Hentakan Balik Kinetik (Kinetic Recoil) [t: 0.365 - 0.43] — Kedua ksatria terpental balik akibat daya benturan yang mahadasyat, sembari 16 cabang petir fraktal meledak memenuhi layar.
/// 8. Penyingkapan Lambang JAVARA & Pemuatan Budaya [t: 0.48 - 1.00] — Aura Surya Mandala memusat membuka lambang asli JAVARA dengan Aksara Jawa `ꦗ ꦮ ꦫ` dan bilah pemuatan budaya menuju Candi Bentar Welcome Screen.
class JavaraCinematicIntro extends StatefulWidget {
  const JavaraCinematicIntro({
    super.key,
    required this.onComplete,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onRegisterAction,
    this.initialProgress = 0.0,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 6400),
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
  bool _isCompleted = false;

  // Status teks tahapan pemuatan budaya menuju halaman berikutnya
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
        _completeOnce();
      });
    }
  }

  void _completeOnce() {
    if (_isCompleted || !mounted) return;
    _isCompleted = true;
    widget.onComplete();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat seluruh aset gambar ke memori GPU untuk performa tanpa stutter
    precacheImage(const AssetImage('assets/images/gatotkaca_clash.png'), context);
    precacheImage(const AssetImage('assets/images/aswatama_clash.png'), context);
  }

  void _handleAnimationProgress() {
    final v = _controller.value;
    // Pembaruan teks tahapan pemuatan saat Scene Logo aktif (t: 0.52 s.d 0.90)
    if (v >= 0.52 && v <= 0.90) {
      final sub = ((v - 0.52) / 0.38 * _loadingTexts.length).floor();
      final idx = sub.clamp(0, _loadingTexts.length - 1);
      if (idx != _loadingStep && mounted) {
        setState(() => _loadingStep = idx);
      }
    }
  }

  /// Memutar ulang pengalaman sinematik dari awal
  void replay() {
    HapticFeedback.lightImpact();
    _isCompleted = false;
    setState(() => _loadingStep = 0);
    _controller.forward(from: 0.0).then((_) {
      _completeOnce();
    });
  }

  /// Melewati sinematik langsung menuju penyelesaian (ke Login / Welcome)
  void skip() {
    HapticFeedback.selectionClick();
    _controller.stop();
    _completeOnce();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationProgress);
    _controller.dispose();
    super.dispose();
  }

  /// Kinematika Benturan 5 Tahap Terinspirasi Adegan Hulkbuster vs Hulk:
  /// Output: [dispFraction, leanAngle, isPreArcActive, preArcIntensity]
  /// - dispFraction: Jarak relatif dari titik benturan kepalan (0.0 = knuckle ketemu persis)
  /// - leanAngle: Sudut kemiringan torso karakter (rad)
  List<double> _evaluateHulkbusterCombatKinematics(double t) {
    if (t < 0.08) {
      return [-1.5, 0.0, 0.0, 0.0];
    }
    if (t > 0.45) {
      return [-0.22, -0.06, 0.0, 0.0];
    }

    // Normalisasi jendela pertarungan (t: 0.08 s.d 0.43)
    final p = ((t - 0.08) / 0.35).clamp(0.0, 1.0);

    // ==============================================================
    // TAHAP 1: Pendekatan Horisontal Cepat (p: 0.00 -> 0.35 | t: 0.08 -> 0.20)
    // Gatotkaca dari kiri, Aswatama dari kanan meluncur ke jarak standoff
    // ==============================================================
    if (p < 0.35) {
      final sub = p / 0.35;
      final easeIn = 1.0 - math.pow(1.0 - sub, 3).toDouble();
      final disp = -1.25 + 0.87 * easeIn; // Dari -1.25 ke -0.38
      final lean = 0.04 * (1.0 - sub);
      return [disp, lean, 0.0, 0.0];
    }

    // ==============================================================
    // TAHAP 2: Tarikan Pukulan & Anticipation Wind-Up (p: 0.35 -> 0.58 | t: 0.20 -> 0.28)
    // Kedua ksatria menarik kepalan tinju dan torso ke belakang (coiling power)
    // ==============================================================
    else if (p < 0.58) {
      final sub = (p - 0.35) / 0.23;
      final pull = 0.5 - 0.5 * math.cos(sub * math.pi);
      final disp = -0.38 - 0.16 * pull; // Menarik ke belakang dari -0.38 ke -0.54
      final lean = -0.10 * pull; // Torso condong ke belakang menahan regangan tenaga
      final arcIntensity = pull; // Busur listrik tegangan tinggi mulai memercik
      return [disp, lean, 1.0, arcIntensity];
    }

    // ==============================================================
    // TAHAP 3: Lontaran Pukulan Eksplosif Menuju Pusat (p: 0.58 -> 0.74 | t: 0.28 -> 0.335)
    // Percepatan masif melesatkan tinju ke titik tengah (Cubic In)
    // ==============================================================
    else if (p < 0.74) {
      final sub = (p - 0.58) / 0.16;
      final thrust = math.pow(sub, 3.4).toDouble();
      final disp = -0.54 + 0.54 * thrust; // Melesat cepat dari -0.54 ke 0.000 persis!
      final lean = -0.10 + 0.16 * thrust; // Bergeser dari condong belakang ke dorongan kuat (+0.06)
      final arcIntensity = (1.0 - sub * 0.5);
      return [disp, lean, 1.0, arcIntensity];
    }

    // ==============================================================
    // TAHAP 4: Buku-Jari Bertemu Buku-Jari & Freeze Frame (p: 0.74 -> 0.84 | t: 0.335 -> 0.365)
    // Hit-stop: kepalan tangan terkunci knuckle-to-knuckle di 0.000 (0px gap)
    // ==============================================================
    else if (p < 0.84) {
      const disp = 0.000; // TEPAT DI TITIK IMPAK BUKU JARI
      const lean = 0.06; // Mempertahankan dorongan benturan penuh
      return [disp, lean, 0.0, 0.0];
    }

    // ==============================================================
    // TAHAP 5: Hentakan Balik Kinetik / Recoil (p: 0.84 -> 1.00 | t: 0.365 -> 0.43)
    // Daya benturan memantulkan kedua ksatria ke belakang
    // ==============================================================
    else {
      final sub = (p - 0.84) / 0.16;
      final recoil = 1.0 - math.pow(1.0 - sub, 2).toDouble();
      final disp = -0.20 * recoil; // Terpental mundur ke -0.20 (~60-70px)
      final lean = 0.06 - 0.14 * recoil; // Torso terpental ke belakang (-0.08)
      return [disp, lean, 0.0, 0.0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Titik pusat benturan kepalan tinju di layar (golden ratio horisontal)
    final collisionCenter = Offset(w * 0.50, h * 0.38);

    // Dimensi gambar ksatria responsif
    final charSize = (w * 0.72).clamp(280.0, 380.0);

    // Titik buku-jari tinju terukur sub-piksel dari data piksel aset gambar asli:
    // Gatotkaca (1024x1024): knuckle depan x=1004 (0.9805), y=468 (0.4570)
    // Aswatama (1024x1024): knuckle depan x=91 (0.0889), y=576 (0.5630)
    final gatotFistXRel = charSize * 0.9805;
    final gatotFistYRel = charSize * 0.4570;

    final aswatFistXRel = charSize * 0.0889;
    final aswatFistYRel = charSize * 0.5630;

    // Posisi target agar buku-jari kedua tinju bertemu PERSIS di `collisionCenter`
    final gatotImpactX = collisionCenter.dx - gatotFistXRel;
    final gatotImpactY = collisionCenter.dy - gatotFistYRel;

    final aswatImpactX = collisionCenter.dx - aswatFistXRel;
    final aswatImpactY = collisionCenter.dy - aswatFistYRel;

    // Jarak lintasan serang horisontal
    final strikeDistance = charSize * 0.92;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // Kinematika Hulkbuster vs Hulk
        final kin = _evaluateHulkbusterCombatKinematics(t);
        final dispFraction = kin[0];
        final leanAngle = kin[1];
        final isPreArcActive = kin[2] > 0.5;
        final preArcIntensity = kin[3];

        // Posisi Horisontal Sejajar Murni (Ketinggian Y terkunci di bidang tempur yang sama)
        final gatotCurX = gatotImpactX + dispFraction * strikeDistance;
        final gatotCurY = gatotImpactY;

        final aswatCurX = aswatImpactX - dispFraction * strikeDistance;
        final aswatCurY = aswatImpactY;

        // Sudut rotasi torso (Gatotkaca condong sesuai arah hadap kanan, Aswatama hadap kiri)
        final gatotAngle = leanAngle;
        final aswatAngle = -leanAngle;

        // Opasitas karakter (muncul t: 0.08, lebur halus ke petir t: 0.41 s.d 0.45)
        double charOpacity = 0.0;
        if (t >= 0.08 && t <= 0.45) {
          if (t < 0.12) {
            charOpacity = ((t - 0.08) / 0.04).clamp(0.0, 1.0);
          } else if (t > 0.40) {
            charOpacity = (1.0 - (t - 0.40) / 0.05).clamp(0.0, 1.0);
          } else {
            charOpacity = 1.0;
          }
        }

        // ==============================================================
        // 1. GUNCANGAN KAMERA FILM (Damped Multi-axis Camera Shake)
        // Terpicu tepat pada saat benturan kepalan (t: 0.335 s.d 0.44)
        // ==============================================================
        double shakeX = 0.0;
        double shakeY = 0.0;
        if (t >= 0.335 && t <= 0.44) {
          final impactT = (t - 0.335) / 0.105;
          final decay = math.exp(-impactT * 4.8);
          shakeX = math.sin(impactT * math.pi * 16) * 14.0 * decay;
          shakeY = math.cos(impactT * math.pi * 12) * 9.0 * decay;
        }

        // ==============================================================
        // 2. KILATAN ANAMORPHIC LENS FLARE & CONTACT FLASH (t: 0.335 - 0.43)
        // ==============================================================
        double flashOpacity = 0.0;
        double flareIntensity = 0.0;
        if (t >= 0.335 && t <= 0.43) {
          if (t < 0.355) {
            final p = (t - 0.335) / 0.020;
            flashOpacity = p.clamp(0.0, 1.0);
            flareIntensity = p.clamp(0.0, 1.0);
          } else {
            final p = 1.0 - (t - 0.355) / 0.075;
            flashOpacity = (p * 0.85).clamp(0.0, 1.0);
            flareIntensity = (p * 1.3).clamp(0.0, 1.0);
          }
        }

        // ==============================================================
        // 3. GELOMBANG KEJUT LONJONG VERTIKAL & PETIR FRAKTAL (t: 0.335 - 0.52)
        // ==============================================================
        double shockwaveProgress = 0.0;
        if (t >= 0.335 && t <= 0.49) {
          shockwaveProgress = Curves.easeOutCubic.transform((t - 0.335) / 0.155);
        }

        double lightningProgress = 0.0;
        if (t >= 0.34 && t <= 0.53) {
          lightningProgress = ((t - 0.34) / 0.19).clamp(0.0, 1.0);
        }

        // ==============================================================
        // 4. PENYINGKAPAN LAMBANG JAVARA & LOADING (t: 0.46 s.d 1.00)
        // ==============================================================
        double logoOpacity = 0.0;
        double logoScale = 0.88;
        if (t >= 0.46) {
          if (t < 0.54) {
            final sub = (t - 0.46) / 0.08;
            logoOpacity = Curves.easeOut.transform(sub);
            logoScale = 0.88 + 0.12 * sub;
          } else {
            logoOpacity = 1.0;
            logoScale = 1.0;
          }
        }

        // Garis progres loading (t: 0.52 s.d 0.95)
        double loadingProgress = 0.0;
        if (t >= 0.52) {
          loadingProgress = ((t - 0.52) / 0.43).clamp(0.05, 1.0);
        }

        // Koordinat ujung kepalan tinju aktual saat ini di canvas
        final currentGatotFist = Offset(gatotCurX + gatotFistXRel, gatotCurY + gatotFistYRel);
        final currentAswatFist = Offset(aswatCurX + aswatFistXRel, aswatCurY + aswatFistYRel);

        return GestureDetector(
          onTap: skip, // Ketuk di mana saja untuk langsung melompat
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
                          Color(0xFF0B0715),
                          Color(0xFF130C21),
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
                // LAPISAN VFX: Ekor Plasma Supersonik & Kerucut Mach Horisontal
                // ==========================================
                if (charOpacity > 0.0 && dispFraction < -0.05)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SupersonicFlightVFXPainter(
                        gatotFist: currentGatotFist,
                        aswatFist: currentAswatFist,
                        dispFraction: dispFraction,
                      ),
                    ),
                  ),

                // ==========================================
                // LAPISAN KSATRIA: Gatotkaca & Aswatama (Hulkbuster vs Hulk Mechanics)
                // ==========================================
                if (charOpacity > 0.0) ...[
                  // Gatotkaca (Kiri -> Bergerak Horisontal ke Kanan)
                  Positioned(
                    left: gatotCurX,
                    top: gatotCurY,
                    width: charSize,
                    height: charSize,
                    child: Opacity(
                      opacity: charOpacity,
                      child: Transform.rotate(
                        angle: gatotAngle,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/gatotkaca_clash.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Aswatama (Kanan -> Bergerak Horisontal ke Kiri)
                  Positioned(
                    left: aswatCurX,
                    top: aswatCurY,
                    width: charSize,
                    height: charSize,
                    child: Opacity(
                      opacity: charOpacity,
                      child: Transform.rotate(
                        angle: aswatAngle,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/aswatama_clash.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],

                // Busur Listrik Tegangan Tinggi Sebelum Benturan (Bullet-time Coiling & Thrust)
                if (isPreArcActive && preArcIntensity > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PreImpactMicroArcPainter(
                        gatotFist: currentGatotFist,
                        aswatFist: currentAswatFist,
                        intensity: preArcIntensity,
                      ),
                    ),
                  ),

                // ==========================================
                // LAPISAN BENTURAN: Gelombang Kejut Lonjong Vertikal, Partikel Kinetik & Petir
                // ==========================================
                if (shockwaveProgress > 0.0 || lightningProgress > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HulkbusterClashVFXPainter(
                        centerOffset: collisionCenter,
                        shockwaveProgress: shockwaveProgress,
                        lightningProgress: lightningProgress,
                      ),
                    ),
                  ),

                // Anamorphic Lens Flare (Garis Kilatan Cahaya Horizontal Bioskop 35mm)
                if (flareIntensity > 0.0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AnamorphicFlarePainter(
                        center: collisionCenter,
                        intensity: flareIntensity,
                      ),
                    ),
                  ),

                // Kilatan Cahaya Putih-Emas Kontak Penuh (Contact Overexposure Flash)
                if (flashOpacity > 0.0)
                  Positioned.fill(
                    child: Container(
                      color: Color.fromRGBO(255, 252, 238, flashOpacity * 0.94),
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
                                      color: const Color(0xFFDFB76C).withValues(alpha: 0.38),
                                      blurRadius: 44,
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

                              // Bilah Pemuatan Budaya Menuju Halaman Welcome / Login
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
// CUSTOM VFX PAINTERS: Hulkbuster Vertical Planar Shockwave, Supersonic Wakes,
// Bullet-time Micro-arcs, Anamorphic Lens Flare, and Kinetic Particle Debris
// ============================================================================

/// Melukis jejak plasma supersonik horisontal di belakang kepalan tinju
class _SupersonicFlightVFXPainter extends CustomPainter {
  _SupersonicFlightVFXPainter({
    required this.gatotFist,
    required this.aswatFist,
    required this.dispFraction,
  });

  final Offset gatotFist;
  final Offset aswatFist;
  final double dispFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final intensity = (dispFraction.abs()).clamp(0.0, 1.0);
    if (intensity < 0.05) return;

    // 1. Ekor Plasma Emas Horisontal Gatotkaca (Supersonic Golden Jet Stream)
    final gatotTrailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFC79B3A).withValues(alpha: intensity * 0.45),
          const Color(0xFFFFE599).withValues(alpha: intensity * 0.90),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(gatotFist.dx - 220, gatotFist.dy),
          gatotFist,
        ),
      );

    final gatotPath = Path();
    gatotPath.moveTo(gatotFist.dx - 220, gatotFist.dy);
    gatotPath.lineTo(gatotFist.dx, gatotFist.dy);
    canvas.drawPath(gatotPath, gatotTrailPaint);

    // Kerucut kejut Mach uap emas di sekitar kepalan Gatotkaca
    final conePaintGatot = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.65);
    final coneGatot = Path();
    coneGatot.moveTo(gatotFist.dx - 45, gatotFist.dy - 32);
    coneGatot.lineTo(gatotFist.dx, gatotFist.dy);
    coneGatot.lineTo(gatotFist.dx - 45, gatotFist.dy + 32);
    canvas.drawPath(coneGatot, conePaintGatot);

    // 2. Ekor Asap & Petir Gelap Horisontal Aswatama (Dark Smoky Plasma Wake)
    final aswatTrailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.5
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9E4B7A).withValues(alpha: intensity * 0.85),
          const Color(0xFF4A1E38).withValues(alpha: intensity * 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromPoints(
          aswatFist,
          Offset(aswatFist.dx + 220, aswatFist.dy),
        ),
      );

    final aswatPath = Path();
    aswatPath.moveTo(aswatFist.dx, aswatFist.dy);
    aswatPath.lineTo(aswatFist.dx + 220, aswatFist.dy);
    canvas.drawPath(aswatPath, aswatTrailPaint);

    // Kerucut kejut Mach uap ungu-gelap di sekitar kepalan Aswatama
    final conePaintAswat = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFD67DAE).withValues(alpha: intensity * 0.65);
    final coneAswat = Path();
    coneAswat.moveTo(aswatFist.dx + 45, aswatFist.dy - 32);
    coneAswat.lineTo(aswatFist.dx, aswatFist.dy);
    coneAswat.lineTo(aswatFist.dx + 45, aswatFist.dy + 32);
    canvas.drawPath(coneAswat, conePaintAswat);
  }

  @override
  bool shouldRepaint(covariant _SupersonicFlightVFXPainter old) =>
      old.gatotFist != gatotFist ||
      old.aswatFist != aswatFist ||
      old.dispFraction != dispFraction;
}

/// Melukis busur listrik tegangan tinggi mikro saat penarikan pukulan (Anticipation Coiling)
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
      ).createShader(Rect.fromCircle(center: mid, radius: 55 * intensity));
    canvas.drawCircle(mid, 55 * intensity, glowPaint);

    // 5 busur listrik mikro zig-zag tegangan tinggi
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = Color.fromRGBO(255, 246, 215, intensity);

    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(gatotFist.dx, gatotFist.dy);
      final jitter = (i.isEven ? 10.0 : -10.0) * intensity;
      path.quadraticBezierTo(mid.dx + jitter, mid.dy - jitter * 0.7, aswatFist.dx, aswatFist.dy);
      canvas.drawPath(path, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PreImpactMicroArcPainter old) =>
      old.gatotFist != gatotFist ||
      old.aswatFist != aswatFist ||
      old.intensity != intensity;
}

/// Melukis Anamorphic Lens Flare (Garis Kilatan Cahaya Horizontal Sinematik Film 35mm)
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

    // Garis sorot horizontal panjang membentang selebar layar (35mm Cinema Flare)
    final flarePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF9ED5FF).withValues(alpha: intensity * 0.42),
          const Color(0xFFFFFFFF).withValues(alpha: intensity * 0.98),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, cy - 4.0, w, 8.0));

    canvas.drawRect(Rect.fromLTWH(0, cy - 2.5, w, 5.0), flarePaint);

    // Inti pendaran oval terkompresi
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: intensity),
          const Color(0xFFFFDF9E).withValues(alpha: intensity * 0.65),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 120 * intensity));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 260 * intensity, height: 36 * intensity),
      coreGlowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnamorphicFlarePainter old) =>
      old.center != center || old.intensity != intensity;
}

/// Melukis lapisan awan badai misterius dan dorongan perpindahan massa awan
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

    final push = shockwave * 80.0;

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

/// Melukis Gelombang Kejut Lonjong Vertikal (Hulkbuster Planar Shockwave),
/// 36+ Partikel Kinetik Pentalan, dan 16 Cabang Petir Fraktal
class _HulkbusterClashVFXPainter extends CustomPainter {
  _HulkbusterClashVFXPainter({
    required this.centerOffset,
    required this.shockwaveProgress,
    required this.lightningProgress,
  });

  final Offset centerOffset;
  final double shockwaveProgress;
  final double lightningProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Pendaran Inti Benturan (Radiant Knuckle Core Glow)
    if (shockwaveProgress > 0.0 && shockwaveProgress < 0.75) {
      final coreAlpha = (1.0 - shockwaveProgress / 0.75).clamp(0.0, 1.0);
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: coreAlpha),
            const Color(0xFFFFDF9E).withValues(alpha: coreAlpha * 0.80),
            const Color(0xFFC79B3A).withValues(alpha: coreAlpha * 0.40),
            Colors.transparent,
          ],
          stops: const [0.0, 0.20, 0.50, 1.0],
        ).createShader(
          Rect.fromCircle(center: centerOffset, radius: 140 * (0.3 + shockwaveProgress)),
        );
      canvas.drawCircle(centerOffset, 140 * (0.3 + shockwaveProgress), corePaint);
    }

    // 2. Lembaran Gelombang Kejut Lonjong Vertikal (Hulkbuster Vertical Planar Shockwave)
    // Seperti di Avengers: Age of Ultron, gelombang kejut tinju tegak lurus sumbu pukulan (vertikal)
    if (shockwaveProgress > 0.0) {
      final baseRadius = size.width * 1.15 * shockwaveProgress;
      final ringAlpha = (1.0 - shockwaveProgress).clamp(0.0, 1.0);

      // Cincin lonjong vertikal utama
      final planarShockwavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (16.0 * (1.0 - shockwaveProgress)).clamp(1.4, 16.0)
        ..color = const Color(0xFFFFEAB8).withValues(alpha: ringAlpha * 0.90);

      canvas.drawOval(
        Rect.fromCenter(
          center: centerOffset,
          width: baseRadius * 0.48,  // Kompresi di sumbu dorong pukulan horisontal (X)
          height: baseRadius * 1.35, // Melebar tinggi di bidang vertikal benturan (Y)
        ),
        planarShockwavePaint,
      );

      // Gelombang kejut terluar (aura tipis bergradasi ungu-kencana)
      final outerPlanarPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = const Color(0xFFDDA645).withValues(alpha: ringAlpha * 0.55);

      canvas.drawOval(
        Rect.fromCenter(
          center: centerOffset,
          width: baseRadius * 0.65,
          height: baseRadius * 1.55,
        ),
        outerPlanarPaint,
      );

      // Dispersi tekanan udara atmosferik melingkar lembut di latar belakang
      final ambientWavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0x33FFE599).withValues(alpha: ringAlpha * 0.25);
      canvas.drawCircle(centerOffset, baseRadius * 0.90, ambientWavePaint);
    }

    // 3. 36+ Partikel Kinetik Percikan & Debris Pentalan (Kinetic Sparks & Impact Shards)
    if (shockwaveProgress > 0.0 && shockwaveProgress < 0.85) {
      final pProgress = (shockwaveProgress / 0.85).clamp(0.0, 1.0);
      final pAlpha = (1.0 - pProgress).clamp(0.0, 1.0);

      const int particleCount = 36;
      for (int i = 0; i < particleCount; i++) {
        // Sudut dominan vertikal & diagonal seperti ledakan tumbukan knuckle Hulkbuster
        final isUpward = i % 2 == 0;
        final baseAngle = isUpward ? -math.pi / 2 : math.pi / 2;
        final spreadAngle = baseAngle + ((i % 18) - 9) * 0.14;

        final speed = 140.0 + (i * 23.7 % 220.0);
        final pSize = (1.6 + (i * 7.3 % 3.4)) * (1.0 - pProgress * 0.5);

        // Lintasan partikel dengan gravitasi kinetik
        final dx = centerOffset.dx + math.cos(spreadAngle) * speed * pProgress;
        final dy = centerOffset.dy + math.sin(spreadAngle) * speed * pProgress + (pProgress * pProgress * 35.0);

        final pPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = (i % 3 == 0)
              ? const Color(0xFFFFFFFF).withValues(alpha: pAlpha * 0.95)
              : ((i % 3 == 1)
                  ? const Color(0xFFFFD479).withValues(alpha: pAlpha * 0.85)
                  : const Color(0xFFDF7EAA).withValues(alpha: pAlpha * 0.70));

        canvas.drawCircle(Offset(dx, dy), pSize, pPaint);
      }
    }

    // 4. 16 Cabang Petir Fraktal Menyambar dari Titik Benturan Buku-Jari
    if (lightningProgress > 0.0) {
      final alpha = (lightningProgress < 0.55)
          ? (lightningProgress / 0.55)
          : (1.0 - (lightningProgress - 0.55) / 0.45);

      final boltGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFDFB76C).withValues(alpha: alpha * 0.75);

      final boltCorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.98);

      const int branchCount = 16;
      final maxReach = size.width * 1.05 * lightningProgress;

      for (int i = 0; i < branchCount; i++) {
        final baseAngle = (i * 2 * math.pi / branchCount) + 0.14;
        final path = Path();
        path.moveTo(centerOffset.dx, centerOffset.dy);

        double curX = centerOffset.dx;
        double curY = centerOffset.dy;
        const int steps = 5;
        final stepDist = maxReach / steps;

        for (int s = 1; s <= steps; s++) {
          final jitterAngle = baseAngle + math.sin(i * 3.2 + s * 4.4) * 0.30;
          final targetX = curX + math.cos(jitterAngle) * stepDist;
          final targetY = curY + math.sin(jitterAngle) * stepDist;
          path.lineTo(targetX, targetY);
          curX = targetX;
          curY = targetY;

          // Sub-cabang petir fraktal
          if (s == 2 || s == 3) {
            final subPath = Path();
            subPath.moveTo(curX, curY);
            final subAngle = jitterAngle + (i.isEven ? 0.52 : -0.52);
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
  bool shouldRepaint(covariant _HulkbusterClashVFXPainter old) =>
      old.shockwaveProgress != shockwaveProgress ||
      old.lightningProgress != lightningProgress;
}
