import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/javara_widgets.dart';

/// Kontroller dan Tampilan Sinematik Pembuka JAVARA.
/// Urutan Narasi 9 Adegan:
/// 1. Badai (Storm atmosphere)
/// 2. Gatotkaca melesat dari kiri-bawah
/// 3. Aswatama menukik dari kanan-atas
/// 4. Benturan tinju di tengah, henti sejenak, kilatan putih-emas, gelombang kejut, guncangan layar
/// 5. Petir emas menyambar ke arah kamera
/// 6. Penyingkapan Lambang Asli JAVARA & bilah pemuatan budaya
/// 7. Transisi halimun ke lanskap senja Dataran Tinggi Dieng (Jawa Tengah)
/// 8. Pembukaan gerbang Candi Bentar adiluhung ke kiri dan kanan
/// 9. Penyingkapan bertahap antarmuka Selamat Datang
class JavaraCinematicIntro extends StatefulWidget {
  const JavaraCinematicIntro({
    super.key,
    required this.onComplete,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onRegisterAction,
    this.initialProgress = 0.0,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 8800),
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

  // Status loading step untuk Scene 6
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

  void _handleAnimationProgress() {
    final v = _controller.value;
    // Update loading texts during Scene 6 (t: 0.52 to 0.70)
    if (v >= 0.52 && v <= 0.72) {
      final sub = ((v - 0.52) / 0.20 * _loadingTexts.length).floor();
      final idx = sub.clamp(0, _loadingTexts.length - 1);
      if (idx != _loadingStep && mounted) {
        setState(() => _loadingStep = idx);
      }
    }
  }

  /// Memutar ulang sinematik dari awal
  void replay() {
    HapticFeedback.lightImpact();
    setState(() => _loadingStep = 0);
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  /// Melewati langsung ke adegan gerbang terbuka & UI selamat datang
  void skip() {
    HapticFeedback.selectionClick();
    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 600),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // --- 1. Perhitungan Guncangan Layar (Camera Shake) pada Benturan (t: 0.36 - 0.46) ---
        double shakeX = 0.0;
        double shakeY = 0.0;
        if (t >= 0.36 && t <= 0.46) {
          final impactT = (t - 0.36) / 0.10;
          final decay = 1.0 - impactT;
          shakeX = math.sin(impactT * math.pi * 14) * 12 * decay;
          shakeY = math.cos(impactT * math.pi * 12) * 8 * decay;
        }

        // --- 2. Kilatan Cahaya Putih-Emas (Flash) (t: 0.36 - 0.44) ---
        double flashOpacity = 0.0;
        if (t >= 0.36 && t <= 0.44) {
          if (t < 0.375) {
            flashOpacity = ((t - 0.36) / 0.015).clamp(0.0, 1.0);
          } else {
            flashOpacity = (1.0 - (t - 0.375) / 0.065).clamp(0.0, 1.0);
          }
        }

        // --- 3. Posisi Karakter & Lintas Pertarungan (t: 0.14 - 0.40) ---
        // Gatotkaca (Kiri-Bawah -> Titik Tabrakan Tengah)
        double gatotProgress = 0.0;
        if (t >= 0.14 && t <= 0.36) {
          gatotProgress = Curves.easeInCubic.transform((t - 0.14) / 0.22);
        } else if (t > 0.36 && t <= 0.44) {
          gatotProgress = 1.0; // Henti sejenak saat benturan (Freeze frame)
        }
        final gatotX = -w * 0.70 + (w * 0.70 + (w * 0.5 - 150)) * gatotProgress;
        final gatotY = h * 0.75 - (h * 0.75 - (h * 0.40 - 70)) * gatotProgress;
        final gatotOpacity = (t < 0.14 || t > 0.46) ? 0.0 : (t > 0.42 ? (1.0 - (t - 0.42) / 0.04) : 1.0);

        // Aswatama (Kanan-Atas -> Titik Tabrakan Tengah)
        double aswatProgress = 0.0;
        if (t >= 0.14 && t <= 0.36) {
          aswatProgress = Curves.easeInCubic.transform((t - 0.14) / 0.22);
        } else if (t > 0.36 && t <= 0.44) {
          aswatProgress = 1.0; // Henti sejenak saat benturan (Freeze frame)
        }
        final aswatX = w * 0.70 - (w * 0.70 - (w * 0.5 - 20)) * aswatProgress;
        final aswatY = -h * 0.35 + (h * 0.35 + (h * 0.40 - 90)) * aswatProgress;
        final aswatOpacity = (t < 0.14 || t > 0.46) ? 0.0 : (t > 0.42 ? (1.0 - (t - 0.42) / 0.04) : 1.0);

        // --- 4. Gelombang Kejut Radial (Shockwave) & Petir Cabang (t: 0.36 - 0.56) ---
        double shockwaveProgress = 0.0;
        if (t >= 0.36 && t <= 0.52) {
          shockwaveProgress = Curves.easeOutQuad.transform((t - 0.36) / 0.16);
        }

        // Petir cabang menyambar ke arah kamera (t: 0.36 - 0.58)
        double lightningProgress = 0.0;
        if (t >= 0.36 && t <= 0.56) {
          lightningProgress = ((t - 0.36) / 0.20).clamp(0.0, 1.0);
        }

        // --- 5. Penyingkapan Lambang JAVARA (Scene 6) (t: 0.50 - 0.72) ---
        double logoOpacity = 0.0;
        double logoScale = 0.9;
        if (t >= 0.50 && t <= 0.72) {
          if (t < 0.56) {
            final sub = (t - 0.50) / 0.06;
            logoOpacity = Curves.easeOut.transform(sub);
            logoScale = 0.88 + 0.12 * sub;
          } else if (t <= 0.68) {
            logoOpacity = 1.0;
            logoScale = 1.0;
          } else {
            final sub = (t - 0.68) / 0.04;
            logoOpacity = (1.0 - sub).clamp(0.0, 1.0);
            logoScale = 1.0 + 0.05 * sub;
          }
        }

        // --- 6. Transisi Halus ke Lanskap Dieng (Scene 7) (t: 0.66 - 1.0) ---
        double diengOpacity = 0.0;
        if (t >= 0.66) {
          diengOpacity = Curves.easeInOutCubic.transform(((t - 0.66) / 0.14).clamp(0.0, 1.0));
        }

        // --- 7. Pembukaan Gerbang Candi Bentar (Scene 8) (t: 0.76 - 0.96) ---
        double gateOpenProgress = 0.0;
        if (t >= 0.76) {
          final raw = ((t - 0.76) / 0.18).clamp(0.0, 1.0);
          gateOpenProgress = Curves.easeInOutCubic.transform(raw);
        }
        // Jarak geser pilar gerbang candi ke kiri dan kanan
        final gateShift = (w * 0.36) * gateOpenProgress;

        // --- 8. Penyingkapan Bertahap Welcome UI (Scene 9) (t: 0.86 - 1.0) ---
        double uiOpacity = 0.0;
        double uiSlide = 24.0;
        if (t >= 0.86) {
          final raw = ((t - 0.86) / 0.14).clamp(0.0, 1.0);
          uiOpacity = Curves.easeOutCubic.transform(raw);
          uiSlide = 24.0 * (1.0 - uiOpacity);
        }

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==========================================
              // LAPISAN DASAR: Langit Badai Gelap (Scene 1-6)
              // ==========================================
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF06040A),
                      Color(0xFF0F0B1A),
                      Color(0xFF140F22),
                      Color(0xFF07040B),
                    ],
                  ),
                ),
              ),

              // Awan Badai Bergerak & Pendaran Petir Alam Sekitar
              if (t < 0.75)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StormCloudsPainter(
                      progress: t,
                      shockwave: shockwaveProgress,
                    ),
                  ),
                ),

              // ==========================================
              // LAPISAN LANSKAP SENJA DIENG (Scene 7-9)
              // ==========================================
              if (diengOpacity > 0.0)
                Positioned.fill(
                  child: Opacity(
                    opacity: diengOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Foto Lanskap Gunung Sindoro & Senja Dieng
                        Image.asset(
                          'assets/images/dieng_sunset.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),

                        // Gradasi Hangat Senja & Halimun Dingin Pegunungan
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66181124), // Violet-gray dingin di langit atas
                                Colors.transparent,
                                Color(0x33C78546), // Pendaran amber senja
                                Color(0xDD0D0914), // Dasar gelap dramatis untuk kontras UI
                              ],
                              stops: [0.0, 0.35, 0.65, 1.0],
                            ),
                          ),
                        ),

                        // Kabut Dingin Mengalir Lembut di Kaki Gunung
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MountainMistPainter(
                              time: t * 4.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ==========================================
              // LAPISAN KARAKTER: Gatotkaca & Aswatama (Scene 2-4)
              // ==========================================
              if (gatotOpacity > 0.0)
                Positioned(
                  left: gatotX,
                  top: gatotY,
                  width: 220,
                  height: 220,
                  child: Opacity(
                    opacity: gatotOpacity,
                    child: Transform.rotate(
                      angle: 0.22, // Kemiringan melesat ke atas
                      child: Image.asset(
                        'assets/images/gatotkaca_clash.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              if (aswatOpacity > 0.0)
                Positioned(
                  left: aswatX,
                  top: aswatY,
                  width: 220,
                  height: 220,
                  child: Opacity(
                    opacity: aswatOpacity,
                    child: Transform.rotate(
                      angle: -0.22, // Kemiringan menukik ke bawah
                      child: Image.asset(
                        'assets/images/aswatama_clash.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              // ==========================================
              // LAPISAN BENTURAN: Gelombang Kejut & Petir (Scene 4-5)
              // ==========================================
              if (shockwaveProgress > 0.0 || lightningProgress > 0.0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CollisionClashPainter(
                      centerOffset: Offset(w * 0.5, h * 0.40),
                      shockwaveProgress: shockwaveProgress,
                      lightningProgress: lightningProgress,
                    ),
                  ),
                ),

              // Kilatan Cahaya Putih-Emas Penuh (Full-screen Flash)
              if (flashOpacity > 0.0)
                Positioned.fill(
                  child: Container(
                    color: Color.fromRGBO(255, 252, 235, flashOpacity),
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
                                    color: const Color(0xFFDFB76C).withValues(alpha: 0.35),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: const JavaraLogo(size: 190),
                            ),

                            const SizedBox(height: 24),

                            // Teks Aksara Jawa Luhur
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

                            const SizedBox(height: 36),

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
                                      height: 3.0,
                                      width: 220,
                                      color: const Color(0x33DFB76C),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: ((t - 0.50) / 0.20).clamp(0.1, 1.0),
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
              // ==========================================
              if (diengOpacity > 0.0) ...[
                // Sayap Kiri Candi Bentar (Membuka ke Kiri)
                Positioned(
                  left: -gateShift,
                  top: h * 0.16,
                  bottom: -20,
                  width: w * 0.52,
                  child: Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.15 * gateOpenProgress),
                    child: Image.asset(
                      'assets/images/temple_gate_left.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Sayap Kanan Candi Bentar (Membuka ke Kanan)
                Positioned(
                  right: -gateShift,
                  top: h * 0.16,
                  bottom: -20,
                  width: w * 0.52,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(0.15 * gateOpenProgress),
                    child: Image.asset(
                      'assets/images/temple_gate_right.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
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
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Judul Utama (Headline Editorial Adiluhung)
                                  Text(
                                    'Mengenal warisan.\nMemahami makna.',
                                    style: JText.editorial(
                                      32,
                                      weight: FontWeight.w700,
                                      color: JColors.warmIvory,
                                      height: 1.15,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),

                                  const SizedBox(height: 12),

                                  // Deskripsi Filosofis
                                  Text(
                                    'Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi.',
                                    style: JText.serif(
                                      14.5,
                                      color: const Color(0xFFDED3C4),
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),

                                  const SizedBox(height: 28),

                                  // Tombol Utama: Mulai Eksplorasi Budaya →
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE2B755),
                                          Color(0xFFC79B3A),
                                          Color(0xFFA67C24),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFC79B3A).withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: widget.onPrimaryAction,
                                        child: Center(
                                          child: Text(
                                            'Mulai Eksplorasi Budaya →',
                                            style: JText.sans(
                                              15.5,
                                              weight: FontWeight.w700,
                                              color: const Color(0xFF221708),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tombol Sekunder: Masuk ke Akun Anda
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0x331E1724),
                                      border: Border.all(
                                        color: const Color(0x66DFB76C),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: widget.onSecondaryAction,
                                        child: Center(
                                          child: Text(
                                            'Masuk ke Akun Anda',
                                            style: JText.sans(
                                              14.5,
                                              weight: FontWeight.w600,
                                              color: const Color(0xFFF5EAD8),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Tautan Pendaftaran
                                  GestureDetector(
                                    onTap: widget.onRegisterAction,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RichText(
                                          text: TextSpan(
                                            style: JText.sans(
                                              13.5,
                                              color: const Color(0xFFB8A996),
                                            ),
                                            children: const [
                                              TextSpan(text: 'Belum memiliki akun? '),
                                              TextSpan(
                                                text: 'Daftar di sini',
                                                style: TextStyle(
                                                  color: Color(0xFFE2B755),
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Color(0xFFE2B755),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0x661E1724),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x44DFB76C),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.replay_rounded,
                                    size: 14,
                                    color: Color(0xFFDFB76C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Putar Ulang',
                                    style: JText.sans(
                                      11.5,
                                      weight: FontWeight.w600,
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
                                color: const Color(0x55000000),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x33FFFFFF),
                                  width: 1.0,
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
// CUSTOM PAINTERS: Awan Badai, Gelombang Kejut, Petir Fraktal, Kabut Dieng
// ============================================================================

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

    // Pergeseran awan horizontal perlahan
    final drift = (progress * 40.0) % w;

    final cloudPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45)
      ..style = PaintingStyle.fill;

    // Dorongan awan keluar saat gelombang kejut meledak
    final push = shockwave * 80.0;

    // Gumpalan awan atas
    cloudPaint.color = const Color(0x551E1430);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.3 + drift * 0.5 - push, h * 0.18 - push * 0.5),
        width: w * 0.9,
        height: h * 0.28,
      ),
      cloudPaint,
    );

    cloudPaint.color = const Color(0x442C1B42);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.75 - drift * 0.3 + push, h * 0.26 - push * 0.5),
        width: w * 0.85,
        height: h * 0.24,
      ),
      cloudPaint,
    );

    // Gumpalan awan bawah
    cloudPaint.color = const Color(0x66110D1A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5 + push, h * 0.85 + push),
        width: w * 1.2,
        height: h * 0.35,
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
    final cx = centerOffset.dx;
    final cy = centerOffset.dy;

    // 1. Pendaran Inti Benturan (Center Radiant Core)
    if (shockwaveProgress > 0.0 && shockwaveProgress < 0.8) {
      final coreAlpha = (1.0 - shockwaveProgress / 0.8).clamp(0.0, 1.0);
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: coreAlpha),
            const Color(0xFFFFDF9E).withValues(alpha: coreAlpha * 0.8),
            const Color(0xFFC79B3A).withValues(alpha: coreAlpha * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: centerOffset, radius: 140 * (0.3 + shockwaveProgress)),
        );
      canvas.drawCircle(centerOffset, 140 * (0.3 + shockwaveProgress), corePaint);
    }

    // 2. Cincin Gelombang Kejut Radial (Expanding Shockwave Ring)
    if (shockwaveProgress > 0.0) {
      final ringRadius = size.width * 1.25 * shockwaveProgress;
      final ringAlpha = (1.0 - shockwaveProgress).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (16.0 * (1.0 - shockwaveProgress)).clamp(1.5, 16.0)
        ..color = const Color(0xFFFFEAB8).withValues(alpha: ringAlpha * 0.85);

      canvas.drawCircle(centerOffset, ringRadius, ringPaint);

      // Cincin kedua yang lebih halus
      final outerRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = const Color(0xFFC79B3A).withValues(alpha: ringAlpha * 0.5);

      canvas.drawCircle(centerOffset, ringRadius * 0.85, outerRingPaint);
    }

    // 3. Petir Fraktal Bercabang Menyambar ke Kamera (Branching Lightning Arcs)
    if (lightningProgress > 0.0) {
      final alpha = (lightningProgress < 0.6)
          ? (lightningProgress / 0.6)
          : (1.0 - (lightningProgress - 0.6) / 0.4);

      final boltGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFDFB76C).withValues(alpha: alpha * 0.7);

      final boltCorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.95);

      // Gambar 10 cabang petir utama dengan sudut radial deterministik
      const int branchCount = 10;
      final maxReach = size.width * 0.95 * lightningProgress;

      for (int i = 0; i < branchCount; i++) {
        final baseAngle = (i * 2 * math.pi / branchCount) + 0.15;
        final path = Path();
        path.moveTo(cx, cy);

        double curX = cx;
        double curY = cy;
        const int steps = 5;
        final stepDist = maxReach / steps;

        for (int s = 1; s <= steps; s++) {
          final jitterAngle = baseAngle + math.sin(i * 3.0 + s * 4.5) * 0.35;
          final targetX = curX + math.cos(jitterAngle) * stepDist;
          final targetY = curY + math.sin(jitterAngle) * stepDist;
          path.lineTo(targetX, targetY);
          curX = targetX;
          curY = targetY;

          // Anak cabang petir (Sub-branch)
          if (s == 2 || s == 3) {
            final subPath = Path();
            subPath.moveTo(curX, curY);
            final subAngle = jitterAngle + (i.isEven ? 0.6 : -0.6);
            subPath.lineTo(
              curX + math.cos(subAngle) * stepDist * 0.6,
              curY + math.sin(subAngle) * stepDist * 0.6,
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

/// Melukis kabut dingin pegunungan Dieng yang mengalir lembut
class _MountainMistPainter extends CustomPainter {
  _MountainMistPainter({required this.time});
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mistPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50)
      ..style = PaintingStyle.fill;

    // Gelombang halimun 1
    final offset1 = math.sin(time * 0.5) * 30.0;
    mistPaint.color = const Color(0x356A798C);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.4 + offset1, h * 0.72),
        width: w * 1.3,
        height: 120,
      ),
      mistPaint,
    );

    // Gelombang halimun 2
    final offset2 = math.cos(time * 0.4) * 25.0;
    mistPaint.color = const Color(0x2897A4B8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.6 + offset2, h * 0.82),
        width: w * 1.4,
        height: 140,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MountainMistPainter old) => old.time != time;
}
