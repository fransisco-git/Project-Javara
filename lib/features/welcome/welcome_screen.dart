import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';

/// Layar Selamat Datang JAVARA — Cinematic Candi Bentar Gate Opening Experience.
///
/// Disusun dalam 2 bagian sinematik berseni tinggi:
///
/// **Bagian 1: Gerbang Tertutup & Badai (Part 1: The Closed Gate & Storm)**
/// - Tampilan close-up gerbang batu candi kuno Jawa Tengah yang tertutup rapat.
/// - Di atas gerbang, langit badai berkabut gelap dengan awan berputar dan kilatan
///   petir dramatis yang menerangi rekahan awan serta tekstur batu andesit.
/// - Suasana hening, mistis, dan berbobot magis.
///
/// **Bagian 2: Terbukanya Gerbang & Tersingkapnya Panorama (Part 2: The Opening & The Reveal)**
/// - Dua daun gerbang batu raksasa meluncur megah ke arah luar (kiri & kanan)
///   dengan kelembaman batu alami dan rotasi perspektif 3D.
/// - Berkas cahaya keemasan hangat yang sangat terang memancar intens dari celah gerbang,
///   mengusir kegelapan badai seketika.
/// - Kamera melakukan dynamic zoom-out dan dorongan maju (push-through) melewati gerbang.
/// - Menyingkap lanskap kompleks candi dan panorama megah jajaran pegunungan Dieng
///   di bawah langit cerah dengan sinar mentari fajar dan awan lembut.
/// - Tipografi editorial luhur dan tombol aksi mengalir masuk dengan anggun.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.playGateOpen = true,
  });

  final bool playGateOpen;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _gateController;
  late final AnimationController _ambientController;
  Timer? _initialDelayTimer;

  @override
  void initState() {
    super.initState();

    // Kontroler utama sekuens sinematik 2-bagian (3800ms)
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    // Kontroler ambien berkelanjutan (denyut surya, halimun kabut, & partikel)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    if (widget.playGateOpen) {
      _initialDelayTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          _gateController.forward();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat aset gambar ke GPU cache untuk rendering instan bebas lag
    precacheImage(const AssetImage('assets/images/user_candi_landscape.jpg'), context);
    precacheImage(const AssetImage('assets/images/user_gate_left_cut.png'), context);
    precacheImage(const AssetImage('assets/images/user_gate_right_cut.png'), context);
    precacheImage(const AssetImage('assets/images/dieng_sunset_reflection.jpg'), context);
  }

  @override
  void dispose() {
    _initialDelayTimer?.cancel();
    _gateController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _skipToOpen() {
    if (_gateController.value < 1.0) {
      HapticFeedback.lightImpact();
      _gateController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _replaySequence() {
    HapticFeedback.mediumImpact();
    _gateController.forward(from: 0.0);
  }

  void _onPrimaryExplore() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(const HomeScreen()),
    );
  }

  void _onLoginAction() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const LoginScreen()),
    );
  }

  void _onSignUpAction() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Dimensi gerbang terhitung proporsional terhadap layar ponsel
    final gateHeight = (h * 0.82).clamp(420.0, 780.0);
    // Aspect ratio user_gate_cut: 275 / 1024 = 0.26855
    final gateWidth = gateHeight * (275.0 / 1024.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF040206),
        body: AnimatedBuilder(
          animation: Listenable.merge([_gateController, _ambientController]),
          builder: (context, _) {
            final t = _gateController.value;
            final ambientT = _ambientController.value;

            // ============================================================
            // KINEMATIKA 2 TAHAP:
            // ------------------------------------------------------------
            // Tahap 1 (t: 0.00 -> 0.28): Gerbang tertutup rapat, badai gelap, petir
            // Tahap 2 (t: 0.28 -> 1.00): Retakan cahaya emas, dorongan kamera,
            //                            gerbang meluncur ke samping & panorama tersingkap
            // ============================================================

            // 1. Progres Pembukaan Gerbang (Mulai bergerak pada t >= 0.28)
            double openProgress = 0.0;
            if (t >= 0.28) {
              final raw = ((t - 0.28) / 0.58).clamp(0.0, 1.0);
              openProgress = Curves.easeInOutCubic.transform(raw);
            }

            // Jarak geser daun gerbang ke kiri & kanan (melebihi tepi layar)
            final maxShift = (w * 0.50) + (gateWidth * 0.35);
            final gateShift = maxShift * openProgress;

            // Sudut rotasi 3D daun gerbang (buka ke luar seperti sayap candi bentar)
            final gateRotationY = (1.0 - openProgress) * 0.08 * math.pi;

            // 2. Kilatan Petir & Badai Gelap (Tahap 1)
            double lightningAlpha = 0.0;
            if (t >= 0.06 && t <= 0.13) {
              final p = (t - 0.06) / 0.07;
              lightningAlpha = math.sin(p * math.pi) * 0.85;
            } else if (t >= 0.18 && t <= 0.25) {
              final p = (t - 0.18) / 0.07;
              final sub = (p * 2.0).clamp(0.0, 1.0);
              lightningAlpha = (math.sin(sub * math.pi) * 0.95);
            }

            // Opasitas lapisan badai & kegelapan (meluruh drastis saat gerbang membuka)
            final stormOpacity = (1.0 - (openProgress * 1.35)).clamp(0.0, 1.0);

            // 3. Berkas Sinar Emas Merekah (Golden God-Rays & Light Burst)
            double goldenLightIntensity = 0.0;
            if (t >= 0.24 && t <= 0.75) {
              if (t < 0.42) {
                goldenLightIntensity = ((t - 0.24) / 0.18).clamp(0.0, 1.0);
              } else {
                goldenLightIntensity = (1.0 - ((t - 0.42) / 0.33)).clamp(0.0, 1.0);
              }
            }

            // 4. Dorongan Kamera Maju (Push-Through & Dynamic Zoom)
            final cameraScale = 1.14 - (openProgress * 0.14);
            final cameraShake = lightningAlpha > 0.1
                ? Offset(
                    math.sin(t * 80.0) * 2.5 * lightningAlpha,
                    math.cos(t * 80.0) * 2.5 * lightningAlpha,
                  )
                : Offset.zero;

            // 5. Kemunculan UI Editorial (Mulai aktif saat gerbang terbuka 65%)
            double uiOpacity = 0.0;
            double uiSlideY = 24.0;
            if (t >= 0.65) {
              final sub = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
              uiOpacity = Curves.easeOutCubic.transform(sub);
              uiSlideY = (1.0 - uiOpacity) * 24.0;
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: openProgress < 0.9 ? _skipToOpen : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ============================================================
                  // 1. LAPISAN PEMANDANGAN LATAR BELAKANG (Panoramic Vista & Mountains)
                  // ============================================================
                  Positioned.fill(
                    child: Transform.translate(
                      offset: cameraShake,
                      child: Transform.scale(
                        scale: cameraScale,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/user_candi_landscape.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),

                  // Pendaran Surya Fajar Keemasan di Balik Puncak Pegunungan
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiengSunsetGlowPainter(
                        ambientTime: ambientT,
                        openProgress: openProgress,
                      ),
                    ),
                  ),

                  // Kabut Pegunungan Dieng Merayap Lembut (Parallax Mist)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiengParallaxMistPainter(
                        time: ambientT,
                        openProgress: openProgress,
                      ),
                    ),
                  ),

                  // Partikel Keemasan Melayang di Udara (Sunlight Motes)
                  if (openProgress > 0.20)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SunlightMotesPainter(
                          time: ambientT,
                          progress: openProgress,
                        ),
                      ),
                    ),

                  // ============================================================
                  // 2. LAPISAN BADAI & KEGELAPAN (Part 1: Storm Cloudscape & Lightning)
                  // ============================================================
                  if (stormOpacity > 0.0) ...[
                    // Gradien Langit Badai Gelap Kosmik
                    Positioned.fill(
                      child: Opacity(
                        opacity: stormOpacity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF040207),
                                const Color(0xFF0C0717).withValues(alpha: 0.95),
                                const Color(0xFF140C26).withValues(alpha: 0.88),
                                const Color(0xFF060309),
                              ],
                              stops: const [0.0, 0.32, 0.70, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Awan Berputar & Kilatan Petir Fraktal (Storm Cloudscape Painter)
                    Positioned.fill(
                      child: Opacity(
                        opacity: stormOpacity,
                        child: CustomPaint(
                          painter: _StormCloudscapePainter(
                            progress: t,
                            lightningAlpha: lightningAlpha,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Kilatan Putih Terang Sesaat saat Petir Menyambar (Flash Burst)
                  if (lightningAlpha > 0.05 && stormOpacity > 0.2)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: Color.fromRGBO(245, 238, 255, 0.28 * lightningAlpha),
                        ),
                      ),
                    ),

                  // ============================================================
                  // 3. BERKAS SINAR EMAS MEREKAH DARI CELAH GERBANG (Part 2: Light Rays)
                  // ============================================================
                  if (goldenLightIntensity > 0.0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GoldenGodRaysPainter(
                            intensity: goldenLightIntensity,
                            openProgress: openProgress,
                            screenCenter: Offset(w * 0.50, h * 0.44),
                          ),
                        ),
                      ),
                    ),

                  // ============================================================
                  // 4. DAUN GERBANG BATU CANDI BENTAR (Smooth 2D/3D Sliding & Perspective)
                  // ============================================================
                  if (openProgress < 0.98) ...[
                    // Daun Pintu Kiri Candi Bentar
                    Positioned(
                      top: h * 0.07,
                      right: (w * 0.50) + gateShift,
                      width: gateWidth,
                      height: gateHeight,
                      child: Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..rotateY(-gateRotationY),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: (0.75 * (1.0 - openProgress)).clamp(0.0, 0.75),
                                ),
                                blurRadius: 28,
                                offset: const Offset(-8, 12),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/user_gate_left_cut.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),

                    // Daun Pintu Kanan Candi Bentar
                    Positioned(
                      top: h * 0.07,
                      left: (w * 0.50) + gateShift,
                      width: gateWidth,
                      height: gateHeight,
                      child: Transform(
                        alignment: Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..rotateY(gateRotationY),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: (0.75 * (1.0 - openProgress)).clamp(0.0, 0.75),
                                ),
                                blurRadius: 28,
                                offset: const Offset(8, 12),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/user_gate_right_cut.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                    ),

                    // Efek Silau Garis Vertikal di Pertemuan Gerbang saat Pertama Membuka
                    if (openProgress > 0.0 && openProgress < 0.35)
                      Positioned(
                        top: h * 0.07,
                        bottom: h * 0.20,
                        left: (w * 0.50) - 2.5,
                        width: 5.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xFFFFF7DB),
                                Color(0xFFFFE89E),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFDF9E).withValues(alpha: 0.9),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],

                  // ============================================================
                  // 5. BILAH ATAS: Aksara Jawa & Tombol Putar Ulang Animasi
                  // ============================================================
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Tombol Putar Ulang Sekuens Sinematik
                            if (openProgress > 0.85)
                              FadeTransition(
                                opacity: AlwaysStoppedAnimation(uiOpacity),
                                child: InkWell(
                                  onTap: _replaySequence,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0x33000000),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x44DFB76C),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.replay_rounded,
                                          size: 13,
                                          color: Color(0xFFDFB76C),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Buka Gerbang',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFDF9E),
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 32),

                            // Indikator Aksara Jawa Halus
                            const Text(
                              'ꦗ ꦮ ꦫ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xAADFB76C),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ============================================================
                  // 6. KONTEN SELAMAT DATANG EDITORIAL (Restrained & Dominant Landscape)
                  // ============================================================
                  if (uiOpacity > 0.0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: uiOpacity,
                        child: Transform.translate(
                          offset: Offset(0, uiSlideY),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              h < 700 ? 16 : 28,
                              20,
                              math.max(MediaQuery.of(context).padding.bottom + 6, 20.0),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF07040C).withValues(alpha: 0.45),
                                  const Color(0xFF050308).withValues(alpha: 0.90),
                                  const Color(0xFF040206).withValues(alpha: 0.98),
                                ],
                                stops: const [0.0, 0.28, 0.65, 1.0],
                              ),
                            ),
                            child: SafeArea(
                              top: false,
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Aksara Jawa & Garis Pembatas Halus
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 0.8,
                                          color: const Color(0x55DFB76C),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'ꦗ ꦮ ꦫ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFDFB76C),
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 6,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 22,
                                          height: 0.8,
                                          color: const Color(0x55DFB76C),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Headline: "Mengenal warisan.\nMemahami makna."
                                    Text(
                                      'Mengenal warisan.\nMemahami makna.',
                                      style: JText.serif(
                                        26,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFF7EFE4),
                                      ).copyWith(
                                        height: 1.22,
                                        letterSpacing: -0.3,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0xAA000000),
                                            blurRadius: 14,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 10),

                                    // Deskripsi Khasanah Busana Adat
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi.',
                                        style: JText.sans(
                                          13.5,
                                          color: const Color(0xFFC8BDB2),
                                          weight: FontWeight.w400,
                                        ).copyWith(
                                          height: 1.55,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x99000000),
                                              blurRadius: 10,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Tombol Utama: "Mulai Eksplorasi Budaya →"
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _onPrimaryExplore,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E1712),
                                          foregroundColor: const Color(0xFFF7EFE4),
                                          elevation: 4,
                                          shadowColor: const Color(0x44000000),
                                          side: const BorderSide(
                                            color: Color(0x88DFB76C),
                                            width: 1.1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Mulai Eksplorasi Budaya',
                                                style: JText.sans(
                                                  15.5,
                                                  weight: FontWeight.w600,
                                                  color: const Color(0xFFF7EFE4),
                                                ).copyWith(letterSpacing: 0.4),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 17,
                                                color: Color(0xFFDFB76C),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Tombol Sekunder: "Masuk ke Akun Anda"
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: TextButton(
                                        onPressed: _onLoginAction,
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFFC8BDB2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Masuk ke Akun Anda',
                                            style: JText.sans(
                                              14,
                                              weight: FontWeight.w500,
                                              color: const Color(0xFFD6CBC0),
                                            ).copyWith(letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // Tautan Registrasi: "Belum memiliki akun? Daftar di sini"
                                    GestureDetector(
                                      onTap: _onSignUpAction,
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              text: 'Belum memiliki akun? ',
                                              style: JText.sans(
                                                12.5,
                                                color: const Color(0x99B8A996),
                                                weight: FontWeight.w400,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Daftar di sini',
                                                  style: JText.sans(
                                                    12.5,
                                                    color: const Color(0xFFDFB76C),
                                                    weight: FontWeight.w600,
                                                  ).copyWith(
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: const Color(0x66DFB76C),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM CINEMATIC VFX PAINTERS
// ============================================================================

/// Melukis langit badai berawan tebal, vorteks atmosferik, dan sambaran petir
class _StormCloudscapePainter extends CustomPainter {
  _StormCloudscapePainter({
    required this.progress,
    required this.lightningAlpha,
  });

  final double progress;
  final double lightningAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Lapisan Gumpalan Awan Badai Menggulung di Langit Atas
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    final cloudOffset = math.sin(progress * math.pi * 2) * 16.0;

    // Gumpalan awan gelap 1
    cloudPaint.color = const Color(0xFF0F0A1C).withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.35 + cloudOffset, h * 0.16),
        width: w * 0.95,
        height: h * 0.24,
      ),
      cloudPaint,
    );

    // Gumpalan awan gelap 2
    cloudPaint.color = const Color(0xFF160E2A).withValues(alpha: 0.78);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.68 - cloudOffset, h * 0.22),
        width: w * 1.10,
        height: h * 0.28,
      ),
      cloudPaint,
    );

    // 2. Sambaran Petir Fraktal (Momentary Fractal Lightning Flashes)
    if (lightningAlpha > 0.05) {
      final boltGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round
        ..color = Color.fromRGBO(205, 185, 255, 0.75 * lightningAlpha);

      final boltCore = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = Color.fromRGBO(255, 255, 255, 0.95 * lightningAlpha);

      // Cabang petir utama 1
      final path1 = Path();
      path1.moveTo(w * 0.52, h * 0.04);
      path1.lineTo(w * 0.49, h * 0.10);
      path1.lineTo(w * 0.53, h * 0.15);
      path1.lineTo(w * 0.50, h * 0.22);
      path1.lineTo(w * 0.54, h * 0.28);
      path1.lineTo(w * 0.50, h * 0.34);

      // Sub-cabang
      final sub1 = Path();
      sub1.moveTo(w * 0.53, h * 0.15);
      sub1.lineTo(w * 0.58, h * 0.18);
      sub1.lineTo(w * 0.62, h * 0.22);

      canvas.drawPath(path1, boltGlow);
      canvas.drawPath(path1, boltCore);
      canvas.drawPath(sub1, boltGlow);
      canvas.drawPath(sub1, boltCore);

      // Rekahan petir dalam awan (Sheet glow)
      final sheetGlow = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48)
        ..color = Color.fromRGBO(175, 150, 235, 0.38 * lightningAlpha);

      canvas.drawCircle(Offset(w * 0.51, h * 0.18), w * 0.45, sheetGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _StormCloudscapePainter old) =>
      old.progress != progress || old.lightningAlpha != lightningAlpha;
}

/// Melukis berkas cahaya keemasan adiluhung (God-Rays & Radiant Volumetric Beams)
class _GoldenGodRaysPainter extends CustomPainter {
  _GoldenGodRaysPainter({
    required this.intensity,
    required this.openProgress,
    required this.screenCenter,
  });

  final double intensity;
  final double openProgress;
  final Offset screenCenter;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0.01) return;

    final w = size.width;
    final h = size.height;
    final center = screenCenter;

    // 1. Pendaran Inti Putih-Emas (Radiant Core Flare)
    final flarePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 255, 255, 0.95 * intensity),
          Color.fromRGBO(255, 235, 175, 0.75 * intensity),
          Color.fromRGBO(223, 183, 108, 0.40 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.65));

    canvas.drawCircle(center, w * 0.65, flarePaint);

    // 2. 12 Berkas Sinar Keemasan Memancar Tajam (Volumetric Fan Rays)
    const int rayCount = 12;
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * (2 * math.pi / rayCount)) + (openProgress * 0.20);
      final rayLength = math.max(w, h) * 1.3;

      final p1 = Offset(
        center.dx + math.cos(angle - 0.09) * rayLength,
        center.dy + math.sin(angle - 0.09) * rayLength,
      );
      final p2 = Offset(
        center.dx + math.cos(angle + 0.09) * rayLength,
        center.dy + math.sin(angle + 0.09) * rayLength,
      );

      final rayPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      final rayAlpha = ((math.sin(i * 1.8 + openProgress * 4.0).abs() * 0.18 + 0.08) * intensity)
          .clamp(0.0, 1.0);

      rayPaint.color = Color.fromRGBO(255, 230, 150, rayAlpha);
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenGodRaysPainter old) =>
      old.intensity != intensity ||
      old.openProgress != openProgress ||
      old.screenCenter != screenCenter;
}

/// Melukis partikel keemasan melayang lembut di udara (Sunlight Motes)
class _SunlightMotesPainter extends CustomPainter {
  _SunlightMotesPainter({
    required this.time,
    required this.progress,
  });

  final double time;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const int moteCount = 20;
    final motePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < moteCount; i++) {
      final speed = 0.3 + (i * 0.13 % 0.7);
      final baseY = (i * 42.0) % h;
      final driftY = (baseY - (time * 120.0 * speed)) % h;
      final driftX = ((i * 37.0) % w) + math.sin(time * 2 * math.pi + i) * 16.0;

      final moteAlpha = ((math.sin(time * 3 * math.pi + i).abs() * 0.45 + 0.25) * progress)
          .clamp(0.0, 1.0);
      final moteRadius = 1.2 + (i % 3) * 0.8;

      motePaint.color = Color.fromRGBO(255, 235, 175, moteAlpha);
      canvas.drawCircle(Offset(driftX, driftY), moteRadius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunlightMotesPainter old) =>
      old.time != time || old.progress != progress;
}

/// Melukis pendar keemasan surya senja di balik gunung (muted amber & dusty rose)
class _DiengSunsetGlowPainter extends CustomPainter {
  _DiengSunsetGlowPainter({
    required this.ambientTime,
    required this.openProgress,
  });

  final double ambientTime;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (openProgress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    final sunCenter = Offset(w * 0.50, h * 0.38);
    final pulse = 1.0 + 0.05 * math.sin(ambientTime * 2 * math.pi);
    final glowRadius = (w * 0.68) * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(245, 215, 160, 0.36 * openProgress),
          Color.fromRGBO(190, 140, 160, 0.18 * openProgress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: glowRadius));

    canvas.drawCircle(sunCenter, glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _DiengSunsetGlowPainter old) =>
      old.ambientTime != ambientTime || old.openProgress != openProgress;
}

/// Melukis lapisan kabut Dataran Tinggi Dieng yang merayap di atas air
class _DiengParallaxMistPainter extends CustomPainter {
  _DiengParallaxMistPainter({
    required this.time,
    required this.openProgress,
  });

  final double time;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (openProgress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    final mistPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38)
      ..style = PaintingStyle.fill;

    // Lapisan 1: Halimun melayang di sekitar dasar gerbang candi (y: h * 0.58)
    final offset1 = math.sin(time * 2 * math.pi) * 30.0;
    mistPaint.color = Color.fromRGBO(210, 200, 215, 0.16 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.46 + offset1, h * 0.58),
        width: w * 1.15,
        height: 60,
      ),
      mistPaint,
    );

    // Lapisan 2: Kabut dingin tipis di atas permukaan pantulan air (y: h * 0.72)
    final offset2 = math.cos(time * 2 * math.pi * 0.75) * 26.0;
    mistPaint.color = Color.fromRGBO(170, 185, 205, 0.12 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.54 + offset2, h * 0.72),
        width: w * 1.25,
        height: 70,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiengParallaxMistPainter old) =>
      old.time != time || old.openProgress != openProgress;
}
