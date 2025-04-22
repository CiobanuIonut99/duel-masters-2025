import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ExplosionEffectGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(
      ParticleSystemComponent(
        position: size / 2,
        particle: Particle.generate(
          count: 30,
          lifespan: 0.5,
          generator: (i) {
            final direction = (Vector2.random() - Vector2.random()) * 200;
            return AcceleratedParticle(
              acceleration: direction * 0.5,
              speed: direction,
              child: CircleParticle(
                radius: 2 + (i % 2),
                paint: Paint()
                  ..shader = RadialGradient(
                    colors: [
                      Colors.yellowAccent,
                      Colors.orange,
                      Colors.transparent,
                    ],
                  ).createShader(Rect.fromCircle(center: Offset.zero, radius: 6)),
              ),
            );
          },
        ),
      ),
    );
  }
}
