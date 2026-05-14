import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppReveal extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const AppReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration)
        .slideY(begin: offsetY, end: 0, curve: Curves.easeOutCubic);
  }
}
