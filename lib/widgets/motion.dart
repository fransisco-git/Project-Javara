import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Memunculkan child dengan fade + geser halus, berurutan berdasarkan [index].
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 200),
    this.step = const Duration(milliseconds: 70),
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration step;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> {
  bool _shown = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.baseDelay + widget.step * widget.index, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hormati pengaturan "kurangi gerakan" di perangkat.
    final reduce = MediaQuery.of(context).disableAnimations;
    return AnimatedSlide(
      offset: (_shown || reduce) ? Offset.zero : const Offset(0, 0.12),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: (_shown || reduce) ? 1 : 0,
        duration: reduce ? Duration.zero : const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Getar horizontal singkat saat input salah. Panggil `key.currentState?.shake()`.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.child});
  final Widget child;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() {
    if (MediaQuery.of(context).disableAnimations) return;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final dx = math.sin(_c.value * math.pi * 5) * (1 - _c.value) * 10;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
