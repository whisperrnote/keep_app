import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class WhisperrShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const WhisperrShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<WhisperrShimmer> createState() => _WhisperrShimmerState();
}

class _WhisperrShimmerState extends State<WhisperrShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.1,
                0.5 + (_animation.value * 0.1),
                0.9,
              ],
              colors: [
                AppColors.surface2,
                AppColors.borderSubtle,
                AppColors.surface2,
              ],
            ),
          ),
        );
      },
    );
  }
}
