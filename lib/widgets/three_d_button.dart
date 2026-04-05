// lib/widgets/three_d_button.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThreeDButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double elevation;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;

  const ThreeDButton({
    super.key,
    required this.child,
    this.onPressed,
    this.elevation = 10,
    this.gradient,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
  });

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton> {
  double _scale = 1.0;
  bool _hover = false;

  void _onTapDown(TapDownDetails d) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails d) {
    setState(() => _scale = _hover ? 1.02 : 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        LinearGradient(
          colors: [AppColors.purple, AppColors.neonBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final shadow = [
      BoxShadow(
        color: AppColors.purple.withOpacity(0.35),
        offset: Offset(0, widget.elevation / 2),
        blurRadius: widget.elevation + 8,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.06),
        offset: Offset(0, -1),
        blurRadius: 1,
      ),
    ];

    Widget btn = AnimatedContainer(
      duration: Duration(milliseconds: 160),
      transform: Matrix4.identity()..scale(_scale),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: shadow,
      ),
      padding: widget.padding,
      child: Center(child: widget.child),
    );

    final gesture = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: btn,
    );

    if (kIsWeb) {
      // provide hover for web/desktop
      return MouseRegion(
        onEnter: (_) => setState(() {
          _hover = true;
          _scale = 1.02;
        }),
        onExit: (_) => setState(() {
          _hover = false;
          _scale = 1.0;
        }),
        child: gesture,
      );
    }
    return gesture;
  }
}
