import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const ConfettiOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        numberOfParticles: 12,
        gravity: 0.3,
        emissionFrequency: 0.05,
        colors: const [
          Color(0xFFFF6B6B),
          Color(0xFFFFD93D),
          Color(0xFF6BCB77),
          Color(0xFF4D96FF),
          Color(0xFFFF9F43),
          Color(0xFF9B59B6),
        ],
        createParticlePath: (size) {
          final random = Random();
          return random.nextBool()
              ? (Path()
                ..addRect(Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width * 0.6,
                    height: size.height)))
              : (Path()
                ..addOval(Rect.fromCenter(
                    center: Offset.zero,
                    width: size.width * 0.5,
                    height: size.height * 0.5)));
        },
      ),
    );
  }
}
