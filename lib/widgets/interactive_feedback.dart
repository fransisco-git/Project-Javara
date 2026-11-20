import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kartu Interaktif Bernyawa dengan Mikro-Interaksi Hover & Sentuhan Taktil
/// - Pada perangkat sentuh (Mobile): Skala mengecil halus (0.97x) saat ditekan dengan efek getar haptik lembut.
/// - Pada kursor/mouse (Desktop/Web): Mengambang naik (1.018x) dengan pendaran garis batas emas prada.
class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.elevation = 0.0,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double elevation;
  final String? semanticLabel;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveScale = _isPressed
        ? 0.972
        : _isHovered
            ? 1.018
            : 1.0;

    final baseBorder = widget.border ??
        Border.all(
          color: _isHovered
              ? const Color(0xFFDFB76C)
              : const Color(0x33DFB76C),
          width: _isHovered ? 1.2 : 0.8,
        );

    final baseShadow = [
      if (_isHovered)
        BoxShadow(
          color: const Color(0x44DFB76C),
          blurRadius: 14,
          offset: const Offset(0, 4),
        )
      else if (widget.elevation > 0)
        BoxShadow(
          color: const Color(0x66000000),
          blurRadius: widget.elevation * 4,
          offset: Offset(0, widget.elevation * 2),
        ),
    ];

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onLongPress: widget.onLongPress != null
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onLongPress!();
                }
              : null,
          child: AnimatedScale(
            scale: effectiveScale,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              margin: widget.margin,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? const Color(0xFF1E1712),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: baseBorder,
                boxShadow: baseShadow,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pembungkus Skala Interaktif Universal (Universal Interactive Scale)
/// Memberikan respons pegas taktil saat disentuh atau diklik untuk ikon, badge, dan gambar.
class InteractiveScale extends StatefulWidget {
  const InteractiveScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.94,
    this.semanticLabel,
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final String? semanticLabel;
  final bool enableHaptic;

  @override
  State<InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<InteractiveScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          if (widget.enableHaptic) {
            HapticFeedback.selectionClick();
          }
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Tombol Hati Favorit dengan Animasi Letupan Pegas (Favorite Heart Bounce)
/// Saat ditekan, ikon hati membesar secara dramatis lalu kembali ke ukuran semula
/// dengan transisi warna halus antara abu-abu temaram dan merah terakota/emas.
class FavoriteHeartBounce extends StatefulWidget {
  const FavoriteHeartBounce({
    super.key,
    required this.isFavorited,
    required this.onToggle,
    this.size = 22.0,
    this.activeColor = const Color(0xFFE2583E),
    this.inactiveColor = const Color(0xFFA89989),
  });

  final bool isFavorited;
  final ValueChanged<bool> onToggle;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<FavoriteHeartBounce> createState() => _FavoriteHeartBounceState();
}

class _FavoriteHeartBounceState extends State<FavoriteHeartBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.38), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.38, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    final nextState = !widget.isFavorited;
    widget.onToggle(nextState);
    if (nextState) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Icon(
                widget.isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(widget.isFavorited),
                size: widget.size,
                color: widget.isFavorited ? widget.activeColor : widget.inactiveColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Chip Pilihan Kategori dengan Pantulan Pegas & Sorot Emas Halus
class InteractiveChip extends StatefulWidget {
  const InteractiveChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<InteractiveChip> createState() => _InteractiveChipState();
}

class _InteractiveChipState extends State<InteractiveChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFDFB76C)
                : const Color(0xFF221A14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFDFB76C)
                  : const Color(0x33DFB76C),
              width: 0.9,
            ),
            boxShadow: widget.isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x44DFB76C),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 14,
                  color: widget.isSelected
                      ? const Color(0xFF14100D)
                      : const Color(0xFFDFB76C),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: widget.isSelected
                      ? const Color(0xFF14100D)
                      : const Color(0xFFFAF6F0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indikator Pull-to-Refresh Khas JAVARA dengan Palet Emas Prada & Haptik
class JavaraPullRefresh extends StatelessWidget {
  const JavaraPullRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color = const Color(0xFFDFB76C),
    this.backgroundColor = const Color(0xFF1E1712),
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.strokeWidth = 2.4,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final Color color;
  final Color backgroundColor;
  final double displacement;
  final double edgeOffset;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color,
      backgroundColor: backgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: strokeWidth,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await onRefresh();
      },
      child: child,
    );
  }
}
