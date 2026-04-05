// lib/transitions/route_transitions.dart
import 'package:flutter/material.dart';

Route<T> createRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 480),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.02).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
        TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
      ]);
      final scaleAnim = animation.drive(tween);
      final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slideAnim = Tween(begin: Offset(0.08, 0.12), end: Offset.zero).animate(animation);

      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        ),
      );
    },
  );
}
