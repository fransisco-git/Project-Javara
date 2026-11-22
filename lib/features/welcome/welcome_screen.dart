import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';

/// Gaya visual elemen pembuka gerbang pada Layar Selamat Datang
enum GateOpeningVisual {
  /// Daun gerbang batu Candi Bentar klasik Jawa Tengah
  candiGate,

  /// Tangan Buddha 3D dalam gestur Anjali Mudra sembah suci
  buddhaHands,
}

/// Layar Selamat Datang JAVARA — Cinematic 3D Gate Opening & Sacred Dawn Experience.
///
/// Dibangun murni menggunakan animasi kinematika spasial 3D Flutter native
/// (terinspirasi dari presisi gerak Mudra Tangan Buddha):
/// - Bagian 1: Gerbang tertutup rapat di tengah di bawah naungan badai gelap dan kilat dramatis.
/// - Bagian 2: Daun gerbang (atau tangan mudra) meluncur perlahan terbuka ke arah luar (kiri & kanan)
///   dengan rotasi 3D yaw, pitch, dan roll yang agung.
/// - Berkas sinar emas fajar (*golden god rays*) menyembur terang dari celah tengah,
///   mengusir kegelapan badai dan menyingkap panorama megah Candi Borobudur serta pegunungan Dieng.
/// - Mendukung interaksi sentuh bebas (drag/geser manual), putar ulang, dan peralihan mode visual.
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
  late final AnimationController _uiFadeController;

  GateOpeningVisual _selectedVisual = GateOpeningVisual.candiGate;
  bool _isGateFullyOpened = false;

  @override
  void initState() {
    super.initState();

    // Kontroler utama kinematika terbukanya gerbang (durasi 3200ms)
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    // Kontroler ambien berkelanjutan (denyut pendar surya, kabut Dieng, & partikel)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    // Kontroler fade-in antarmuka editorial di bagian bawah
    _uiFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    _gateController.addListener(_onGateAnimationUpdate);

    if (widget.playGateOpen) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          HapticFeedback.mediumImpact();
          _gateController.forward();
        }
      });
    } else {
      _isGateFullyOpened = true;
    }
  }

  void _onGateAnimationUpdate() {
    if (_gateController.value >= 0.70 && !_isGateFullyOpened) {
      setState(() => _isGateFullyOpened = true);
      _uiFadeController.forward();
    } else if (_gateController.value < 0.65 && _isGateFullyOpened) {
      setState(() => _isGateFullyOpened = false);
      _uiFadeController.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat aset gambar ke GPU memori untuk render 60fps tanpa jeda
    precacheImage(
      const AssetImage('assets/images/temple_gate_left.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/temple_gate_right.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/buddha_hand_left.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/buddha_hand_right.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/candi_gate_mountain_dawn.png'),
      context,
    );
  }

  @override
  void dispose() {
    _gateController.removeListener(_onGateAnimationUpdate);
    _gateController.dispose();
    _ambientController.dispose();
    _uiFadeController.dispose();
    super.dispose();
  }

  void _skipToOpen() {
    HapticFeedback.lightImpact();
    _gateController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _replaySequence() {
    HapticFeedback.mediumImpact();
    setState(() => _isGateFullyOpened = false);
    _uiFadeController.reset();
    _gateController.forward(from: 0.0);
  }

  void _toggleVisualMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedVisual = _selectedVisual == GateOpeningVisual.candiGate
          ? GateOpeningVisual.buddhaHands
          : GateOpeningVisual.candiGate;
    });
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
    final centerX = w / 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF040206),
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _gateController,
            _ambientController,
            _uiFadeController,
          ]),
          builder: (context, _) {
            final gateT = _gateController.value;
            final ambientT = _ambientController.value;

            // Kurva dinamis kinematika pembukaan (easeInOutCubic)
            final openProgress = Curves.easeInOutCubic.transform(gateT);

            // ============================================================
            // PERHITUNGAN GEOMETRI & KINEMATIKA 3D (DARI TERTUTUP KE TERBUKA)
            // ============================================================
            double leftTargetX;
            double rightTargetX;
            double targetY;
            double elemWidth;
            double elemHeight;
            Matrix4 leftMatrix;
            Matrix4 rightMatrix;

            if (_selectedVisual == GateOpeningVisual.candiGate) {
              // Dimensi pilar gerbang candi bentar
              elemHeight = (h * 0.72).clamp(420.0, 680.0);
              elemWidth = elemHeight * (512.0 / 1024.0); // Rasio 0.5
              targetY = (h * 0.08).clamp(30.0, 90.0);

              // Posisi tertutup rapat di tengah vs posisi terbuka membingkai layar
              final leftClosedX = centerX - elemWidth + 2.0;
              final rightClosedX = centerX - 2.0;
              final leftOpenX = -elemWidth * 0.58;
              final rightOpenX = w - (elemWidth * 0.42);

              leftTargetX = ui.lerpDouble(leftClosedX, leftOpenX, openProgress)!;
              rightTargetX = ui.lerpDouble(rightClosedX, rightOpenX, openProgress)!;

              // Rotasi 3D perspektif gerbang batu saat membuka ke luar
              final yawLeft = ui.lerpDouble(0.0, -0.42, openProgress)!;
              final yawRight = ui.lerpDouble(0.0, 0.42, openProgress)!;
              final pitch = 0.018 * openProgress;

              leftMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(pitch)
                ..rotateY(yawLeft);

              rightMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(pitch)
                ..rotateY(yawRight);
            } else {
              // Dimensi tangan mudra semadi Buddha
              elemHeight = (w * 0.78).clamp(280.0, 420.0);
              final leftW = elemHeight * (682.0 / 735.0);
              final rightW = elemHeight * (694.0 / 735.0);
              elemWidth = leftW;
              targetY = (h * 0.22).clamp(140.0, 240.0);

              // Posisi tertutup rapat di tengah (Anjali Mudra) vs terbuka membingkai candi
              final leftClosedX = centerX - leftW + 3.0;
              final rightClosedX = centerX - 3.0;
              final leftOpenX = -leftW * 0.58;
              final rightOpenX = w - (rightW * 0.42);

              leftTargetX = ui.lerpDouble(leftClosedX, leftOpenX, openProgress)!;
              rightTargetX = ui.lerpDouble(rightClosedX, rightOpenX, openProgress)!;

              // Rotasi 3D telapak tangan dari tegak merapat menuju miring anggun di pojok
              final yawLeft = ui.lerpDouble(0.015, -0.48, openProgress)!;
              final yawRight = ui.lerpDouble(-0.015, 0.48, openProgress)!;
              final rollLeft = ui.lerpDouble(0.0, -0.18, openProgress)!;
              final rollRight = ui.lerpDouble(0.0, 0.18, openProgress)!;

              leftMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0016)
                ..rotateY(yawLeft)
                ..rotateZ(rollLeft);

              rightMatrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0016)
                ..rotateY(yawRight)
                ..rotateZ(rollRight);
            }

            // Dolly Zoom Kamera Maju (Push-Through Effect)
            final cameraScale = 1.14 - (openProgress * 0.14);

            // Lapisan Badai & Kegelapan Awal (Meluruh seiring gerbang membuka)
            final stormOpacity = (1.0 - (openProgress * 1.35)).clamp(0.0, 1.0);

            // Berkas Sinar Emas Merekah (Golden God Rays)
            double goldenLightIntensity = 0.0;
            if (gateT >= 0.20 && gateT <= 0.85) {
              if (gateT < 0.45) {
                goldenLightIntensity = ((gateT - 0.20) / 0.25).clamp(0.0, 1.0);
              } else {
                goldenLightIntensity = (1.0 - ((gateT - 0.45) / 0.40)).clamp(0.0, 1.0);
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: openProgress < 0.85 ? _skipToOpen : null,
              onHorizontalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0.0;
                _gateController.value = (_gateController.value + (delta / w)).clamp(0.0, 1.0);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ============================================================
                  // 1. LATAR BELAKANG PANORAMA CANDI & FAJAR GUNUNG DIENG
                  // ============================================================
                  Positioned.fill(
                    child: Transform.scale(
                      scale: cameraScale,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/candi_gate_mountain_dawn.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/candi_3d_cinema.jpg',
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

                  // Partikel Keemasan Surya Mengapung Lembut di Udara
                  if (openProgress > 0.15)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SunlightMotesPainter(
                          time: ambientT,
                          progress: openProgress,
                        ),
                      ),
                    ),

                  // ============================================================
                  // 2. LAPISAN BADAI KOSMIK & KILATAN AWAL (Part 1: Storm Clouds)
                  // ============================================================
                  if (stormOpacity > 0.0) ...[
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

                    // Awan Badai Berputar
                    Positioned.fill(
                      child: Opacity(
                        opacity: stormOpacity,
                        child: CustomPaint(
                          painter: _StormCloudscapePainter(
                            progress: gateT,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ============================================================
                  // 3. BERKAS SINAR EMAS MEREKAH (Golden God Rays)
                  // ============================================================
                  if (goldenLightIntensity > 0.0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _GoldenGodRaysPainter(
                            intensity: goldenLightIntensity,
                            openProgress: openProgress,
                            screenCenter: Offset(centerX, h * 0.42),
                          ),
                        ),
                      ),
                    ),

                  // ============================================================
                  // 4. KEDUA ELEMEN PEMBUKA (DAUN GERBANG / TANGAN BUDDHA 3D)
                  // ============================================================
                  if (openProgress < 0.98) ...[
                    // --- BAGIAN KIRI ---
                    Positioned(
                      top: targetY,
                      left: leftTargetX,
                      width: elemWidth,
                      height: elemHeight,
                      child: IgnorePointer(
                        child: Transform(
                          transform: leftMatrix,
                          alignment: Alignment.centerRight,
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
                              _selectedVisual == GateOpeningVisual.candiGate
                                  ? 'assets/images/temple_gate_left.png'
                                  : 'assets/images/buddha_hand_left.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- BAGIAN KANAN ---
                    Positioned(
                      top: targetY,
                      left: rightTargetX,
                      width: elemWidth,
                      height: elemHeight,
                      child: IgnorePointer(
                        child: Transform(
                          transform: rightMatrix,
                          alignment: Alignment.centerLeft,
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
                              _selectedVisual == GateOpeningVisual.candiGate
                                  ? 'assets/images/temple_gate_right.png'
                                  : 'assets/images/buddha_hand_right.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ============================================================
                  // 5. BILAH KONTROL ATAS: Aksara Jawa, Putar Ulang, & Mode Switcher
                  // ============================================================
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Tombol Buka Gerbang (Putar Ulang) / Lewati
                            Flexible(
                              flex: 5,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: _isGateFullyOpened
                                    ? FadeTransition(
                                        opacity: _uiFadeController,
                                        child: InkWell(
                                          onTap: _replaySequence,
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x66000000),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0x66DFB76C),
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
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x44000000),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Text(
                                          'Ketuk untuk lewati',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0x99FFFFFF),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Tengah: Aksara Jawa
                            const Flexible(
                              flex: 3,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ꦗ ꦮ ꦫ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xAADFB76C),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Kanan: Switcher Mode (Candi vs Tangan Buddha)
                            Flexible(
                              flex: 4,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: _toggleVisualMode,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x55000000),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x44DFB76C),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _selectedVisual == GateOpeningVisual.candiGate
                                              ? Icons.temple_hindu_outlined
                                              : Icons.spa_outlined,
                                          size: 13,
                                          color: const Color(0xFFDFB76C),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedVisual == GateOpeningVisual.candiGate
                                              ? 'Candi'
                                              : 'Mudra',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFDF9E),
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

                  // ============================================================
                  // 6. KONTEN EDITORIAL SELAMAT DATANG (Fade-In Saat Terbuka)
                  // ============================================================
                  if (_isGateFullyOpened || !widget.playGateOpen)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FadeTransition(
                        opacity: _uiFadeController,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            h < 700 ? 16 : 28,
                            20,
                            math.max(
                              MediaQuery.of(context).padding.bottom + 6,
                              20.0,
                            ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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
                                          color: Color(0xFFDFB76C),
                                          width: 1.2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Mulai Eksplorasi Budaya',
                                              style: JText.sans(
                                                15,
                                                weight: FontWeight.w700,
                                                color: const Color(0xFFFFDF9E),
                                              ).copyWith(
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 17,
                                              color: Color(0xFFFFDF9E),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tombol Masuk ke Akun Anda (Tonal Terang Kontras)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _onLoginAction,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDFB76C),
                                        foregroundColor: const Color(0xFF140C06),
                                        elevation: 2,
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
                                            weight: FontWeight.w700,
                                            color: const Color(0xFF140C06),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Tombol Daftar Akun Baru (Outlined Halus)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 46,
                                    child: OutlinedButton(
                                      onPressed: _onSignUpAction,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFD4C8B8),
                                        side: const BorderSide(
                                          color: Color(0x44DFB76C),
                                          width: 0.8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Daftar Akun Baru',
                                          style: JText.sans(
                                            13.5,
                                            weight: FontWeight.w600,
                                            color: const Color(0xFFD4C8B8),
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
// CUSTOM PAINTERS: Golden God-Rays, Sunlight Motes, Mist, & Storm Cloudscape
// ============================================================================

/// Melukis berkas cahaya surya emas (Golden God Rays) memancar dari celah tengah
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

    final rayPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..style = PaintingStyle.fill;

    const int rayCount = 14;
    final maxRadius = size.height * 0.95;

    for (int i = 0; i < rayCount; i++) {
      final angle = -math.pi / 2 + (i - (rayCount / 2)) * 0.22;
      final rayLength = maxRadius * (0.65 + ((i % 3) * 0.18));

      final p1 = Offset(
        screenCenter.dx + math.cos(angle - 0.08) * rayLength,
        screenCenter.dy + math.sin(angle - 0.08) * rayLength,
      );
      final p2 = Offset(
        screenCenter.dx + math.cos(angle + 0.08) * rayLength,
        screenCenter.dy + math.sin(angle + 0.08) * rayLength,
      );

      final rayPath = Path()
        ..moveTo(screenCenter.dx, screenCenter.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      final alpha = ((math.sin(i * 1.6 + openProgress * 3.5).abs() * 0.18 + 0.08) * intensity)
          .clamp(0.0, 1.0);

      rayPaint.color = Color.fromRGBO(255, 230, 150, alpha);
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenGodRaysPainter old) =>
      old.intensity != intensity ||
      old.openProgress != openProgress ||
      old.screenCenter != screenCenter;
}

/// Melukis partikel keemasan melayang di udara (Sunlight Motes)
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

    const int moteCount = 22;
    final motePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < moteCount; i++) {
      final speed = 0.25 + (i * 0.12 % 0.65);
      final baseY = (i * 40.0) % h;
      final driftY = (baseY - (time * 110.0 * speed)) % h;
      final driftX = ((i * 35.0) % w) + math.sin(time * 2 * math.pi + i) * 14.0;

      final alpha = ((math.sin(time * 3 * math.pi + i).abs() * 0.40 + 0.20) * progress)
          .clamp(0.0, 1.0);
      final radius = 1.2 + (i % 3) * 0.7;

      motePaint.color = Color.fromRGBO(255, 235, 175, alpha);
      canvas.drawCircle(Offset(driftX, driftY), radius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunlightMotesPainter old) =>
      old.time != time || old.progress != progress;
}

/// Melukis pendar surya senja/fajar lembut di balik puncak pegunungan
class _DiengSunsetGlowPainter extends CustomPainter {
  _DiengSunsetGlowPainter({
    required this.ambientTime,
    required this.openProgress,
  });

  final double ambientTime;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sunCenter = Offset(w * 0.50, h * 0.40);
    final pulse = 1.0 + 0.05 * math.sin(ambientTime * 2 * math.pi);
    final glowRadius = (w * 0.68) * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(245, 215, 160, 0.36 * openProgress),
          Color.fromRGBO(190, 140, 160, 0.16 * openProgress),
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

    // Lapisan 1: Halimun melayang di sekitar dasar gerbang candi
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

    // Lapisan 2: Kabut dingin tipis di atas permukaan air
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

/// Melukis awan badai berputar di langit atas
class _StormCloudscapePainter extends CustomPainter {
  _StormCloudscapePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cloudPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32)
      ..style = PaintingStyle.fill;

    cloudPaint.color = const Color.fromRGBO(16, 10, 28, 0.65);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.35, h * 0.18),
        width: w * 0.90,
        height: 110,
      ),
      cloudPaint,
    );

    cloudPaint.color = const Color.fromRGBO(26, 16, 42, 0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.72, h * 0.22),
        width: w * 0.85,
        height: 100,
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StormCloudscapePainter old) =>
      old.progress != progress;
}
