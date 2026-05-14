import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool safeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cloud, const Color(0xFFF9F6F2)],
              ),
            ),
          ),
        ),
        const Positioned(top: -120, right: -60, child: _GlowBlob(size: 220)),
        const Positioned(bottom: -140, left: -80, child: _GlowBlob(size: 260)),
        if (safeArea) SafeArea(child: content) else content,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;

  const _GlowBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            AppColors.accent.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
