import 'package:flutter/material.dart';

/// Efek Shimmer Kilau Berpendar Mewah Khas JAVARA
/// Menggunakan palet kayu jati gelap (#1A130E, #261D15) dan aksen prada emas temaram (#3D2C1C)
/// untuk menghadirkan transisi pemuatan data yang realistis dan elegan.
class JavaraShimmer extends StatefulWidget {
  const JavaraShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF1E1712),
    this.highlightColor = const Color(0xFF38291D),
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<JavaraShimmer> createState() => _JavaraShimmerState();
}

class _JavaraShimmerState extends State<JavaraShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            // Sapuan diagonal kilau emas halus melintasi komponen
            return LinearGradient(
              begin: const Alignment(-1.4, -0.6),
              end: const Alignment(1.4, 0.6),
              stops: [
                (progress - 0.35).clamp(0.0, 1.0),
                progress.clamp(0.0, 1.0),
                (progress + 0.35).clamp(0.0, 1.0),
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Kotak Skeleton Shimmer dengan Sudut Membulat
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.color = const Color(0xFF221A14),
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Lingkaran Skeleton Shimmer (untuk Avatar / Ikon / Logo)
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    super.key,
    required this.size,
    this.color = const Color(0xFF221A14),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Tampilan Skeleton Lengkap Halaman Beranda JAVARA
/// Meniru tata letak persis Beranda (Hero Candi, Kategori, Banner Wardrobe, Kartu Rekomendasi)
/// saat aplikasi pertama kali dibuka atau sedang memuat data terbaru.
class HomeTabSkeletonView extends StatelessWidget {
  const HomeTabSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return JavaraShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 14,
                  ),
                ),
                const SizedBox(width: 12),
                const ShimmerBox(
                  width: 48,
                  height: 48,
                  borderRadius: 14,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1712),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x33DFB76C), width: 0.8),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerBox(width: 110, height: 22, borderRadius: 6),
                      ShimmerCircle(size: 28),
                    ],
                  ),
                  Center(
                    child: Column(
                      children: const [
                        ShimmerCircle(size: 80),
                        SizedBox(height: 12),
                        ShimmerBox(width: 160, height: 16, borderRadius: 6),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerBox(width: 120, height: 14, borderRadius: 6),
                      ShimmerBox(width: 80, height: 28, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: const ShimmerBox(
                      width: double.infinity,
                      height: 36,
                      borderRadius: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tajuk Bagian & Carousel Kartu Busana Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: ShimmerBox(
                    width: double.infinity,
                    height: 18,
                    borderRadius: 6,
                  ),
                ),
                SizedBox(width: 12),
                ShimmerBox(width: 70, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(
                2,
                (i) => Expanded(
                  child: Container(
                    height: 190,
                    margin: EdgeInsets.only(right: i == 0 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1712),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x33DFB76C), width: 0.8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: double.infinity, height: 100, borderRadius: 10),
                        SizedBox(height: 10),
                        ShimmerBox(width: 110, height: 14, borderRadius: 4),
                        SizedBox(height: 6),
                        ShimmerBox(width: 70, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
