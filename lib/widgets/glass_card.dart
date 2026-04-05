// lib/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final Gradient? gradient;
  final BoxConstraints? constraints;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.blur = 12,
    this.gradient,
    this.constraints,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderGradient = LinearGradient(
      colors: [
        AppColors.teal.withOpacity(0.45),
        AppColors.purple.withOpacity(0.25),
        AppColors.neonBlue.withOpacity(0.20),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: constraints,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: gradient ?? AppColors.cardGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.03),
              blurRadius: 1,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
