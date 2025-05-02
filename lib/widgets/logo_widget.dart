import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool animate;
  final bool showText;
  final Color? textColor;

  const LogoWidget({
    super.key,
    this.size = 120,
    this.animate = false,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.indigo.shade600,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: showText
            ? Text(
                'VCCM',
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );

    if (!animate) return logo;

    return logo
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white.withOpacity(0.2),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
        );
  }
} 