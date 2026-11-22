import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';

/// Layar Selamat Datang JAVARA — Cinematic Candi Bentar Gate Opening Experience.
///
/// Mengintegrasikan video referensi resmi pembukaan gerbang candi:
/// - Bagian 1: Gerbang batu candi kuno tertutup rapat di bawah langit badai gelap menggulung.
/// - Bagian 2: Sambaran kilat membelah langit, daun gerbang batu meluncur membuka ke arah luar,
///   memancarkan berkas sinar emas fajar yang menghalau kegelapan, dan menyingkap
///   panorama megah puncak gunung berlatar mentari pagi yang berseri.
/// - Dilengkapi fallback visual beresolusi tinggi, kontrol putar ulang, dan lompat instan (skip).
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
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isGateOpened = false;

  late final AnimationController _uiFadeController;
  late final AnimationController _fallbackController;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _uiFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    _fallbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    if (!widget.playGateOpen) {
      _isGateOpened = true;
    }

    _initializeExperience();
  }

  Future<void> _initializeExperience() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/videos/candi_opening_gemini.mp4',
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isVideoInitialized = true;
      });

      if (widget.playGateOpen) {
        await controller.setVolume(0.0); // Muted by default for smooth startup
        await controller.play();

        controller.addListener(_videoProgressCheck);
      } else {
        await controller.seekTo(controller.value.duration);
        _revealUI();
      }
    } catch (_) {
      // Fallback anggun untuk lingkungan tanpa native video codec / testing
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });

        if (widget.playGateOpen) {
          _fallbackController.forward();
          _fallbackTimer = Timer(const Duration(milliseconds: 2800), () {
            if (mounted) _revealUI();
          });
        }
      }
    }
  }

  void _videoProgressCheck() {
    if (!mounted || _videoController == null) return;

    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;

    // Tampilkan UI editorial saat gerbang telah terbuka luas (sekitar 3.8s)
    if (pos >= const Duration(milliseconds: 3800) && !_isGateOpened) {
      _revealUI();
    }

    // Ketika video mencapai akhir durasi
    if (pos >= dur && dur > Duration.zero) {
      if (!_isGateOpened) {
        _revealUI();
      }
    }
  }

  void _revealUI() {
    if (_isGateOpened) return;
    setState(() => _isGateOpened = true);
    _uiFadeController.forward();
  }

  void _skipToOpen() {
    HapticFeedback.lightImpact();
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.pause();
      _videoController!.seekTo(_videoController!.value.duration);
    }
    _fallbackController.value = 1.0;
    _revealUI();
  }

  void _replaySequence() {
    HapticFeedback.mediumImpact();
    setState(() => _isGateOpened = false);
    _uiFadeController.reset();

    if (_videoController != null && _isVideoInitialized) {
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
    } else {
      _fallbackController.forward(from: 0.0);
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(const Duration(milliseconds: 2800), () {
        if (mounted) _revealUI();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('assets/images/candi_gate_storm_closed.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/candi_gate_mountain_dawn.png'),
      context,
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController?.removeListener(_videoProgressCheck);
    _videoController?.dispose();
    _uiFadeController.dispose();
    _fallbackController.dispose();
    super.dispose();
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
    final h = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF040206),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !_isGateOpened ? _skipToOpen : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // 1. PEMUTAR VIDEO SINEMATIK / POSTER KUNCI
              // ============================================================
              if (_isVideoInitialized && _videoController != null)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              else
                // Fallback Keyframes: transisi halus dari gerbang tertutup ke gerbang terbuka
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _fallbackController,
                    builder: (context, _) {
                      final p = _fallbackController.value;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Gerbang terbuka berlatar pemandangan gunung
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/candi_gate_mountain_dawn.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gerbang tertutup berlatar badai
                          if (p < 0.99)
                            Positioned.fill(
                              child: Opacity(
                                opacity: (1.0 - p).clamp(0.0, 1.0),
                                child: Image.asset(
                                  'assets/images/candi_gate_storm_closed.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

              // ============================================================
              // 2. BILAH ATAS: Aksara Jawa & Tombol Buka Gerbang (Putar Ulang)
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
                        // Tombol Putar Ulang Animasi / Video
                        if (_isGateOpened)
                          FadeTransition(
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
                        else
                          // Indikator "Ketuk untuk Lewati" halus
                          Container(
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
              // 3. KONTEN SELAMAT DATANG EDITORIAL (Restrained & Dominant Landscape)
              // ============================================================
              if (_isGateOpened || !widget.playGateOpen)
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
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
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  const Color(0x66DFB76C),
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
            ],
          ),
        ),
      ),
    );
  }
}
