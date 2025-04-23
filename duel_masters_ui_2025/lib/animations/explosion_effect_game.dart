import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
class ExplosionEffectGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000); // ✅ Fully transparent background

  @override
  Future<void> onLoad() async {
    add(
      ParticleSystemComponent(
        position: size / 2,
        particle: Particle.generate(
          count: 40,
          lifespan: 0.8,
          generator: (i) {
            final angle = Random().nextDouble() * 2 * pi;
            final speed = 150 + Random().nextDouble() * 200;
            final direction = Vector2(cos(angle), sin(angle)) * speed;

            return AcceleratedParticle(
              acceleration: -direction * 0.5,
              speed: direction,
              child: CircleParticle(
                radius: 2 + Random().nextDouble() * 2,
                paint: Paint()
                  ..blendMode = BlendMode.plus
                  ..shader = RadialGradient(
                    colors: [
                      Colors.orangeAccent,
                      Colors.redAccent,
                      Colors.transparent,
                    ],
                  ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8)),
              ),
            );
          },
        ),
      ),
    );
  }
}
