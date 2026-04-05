// lib/widgets/animated_icon_button.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum LottieState { loading, success, fail, pet }

class AnimatedIconButton extends StatelessWidget {
  final LottieState state;
  final double size;
  final bool loop;
  const AnimatedIconButton({super.key, required this.state, this.size = 64, this.loop = true});

  String _assetFor(LottieState s) {
    switch (s) {
      case LottieState.loading:
        return 'assets/lottie/loading.json';
      case LottieState.success:
        return 'assets/lottie/success.json';
      case LottieState.fail:
        return 'assets/lottie/fail.json';
      case LottieState.pet:
        return 'assets/lottie/pet-happy.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assetFor(state);
    return SizedBox(
      height: size,
      width: size,
      child: Lottie.asset(asset, repeat: loop, fit: BoxFit.contain),
    );
  }
}
