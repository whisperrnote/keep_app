import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 25.0,
    this.opacity = 0.7,
    this.borderRadius,
    this.border,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.surface.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
