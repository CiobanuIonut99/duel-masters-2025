// 🚀 Ultimate Premium Card Evolution Effect
import 'package:flutter/material.dart';
import 'dart:math';

class UltimateEvolutionEffect extends StatefulWidget {
  final String cardImagePath;

  const UltimateEvolutionEffect({super.key, required this.cardImagePath});

  @override
  State<UltimateEvolutionEffect> createState() => _UltimateEvolutionEffectState();
}

class _UltimateEvolutionEffectState extends State<UltimateEvolutionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: false);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final colorGradient = RadialGradient(
            colors: [
              Color.lerp(Colors.purple, Colors.cyan, _colorAnimation.value)!,
              Colors.transparent,
            ],
            radius: 0.8,
          );

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Phase 1: pulsing background glow
              Container(
                width: 180,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: colorGradient,
                ),
              ),

              // Phase 2: rotating rune ring
              Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Container(
                  width: 200,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "✦ ✧ ✦",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.amberAccent.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),

              // Phase 3: main card with glowing shadow + slight rotation
              Transform(
                transform: Matrix4.identity()
                  ..scale(1 + 0.05 * sin(_controller.value * pi * 2))
                  ..rotateZ(0.02 * sin(_controller.value * pi * 2)),
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(widget.cardImagePath),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(
                            Colors.blueAccent,
                            Colors.purpleAccent,
                            _colorAnimation.value)!
                            .withOpacity(_glowAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),

              // Phase 4: sparkles
              ...List.generate(12, (index) {
                final angle = (2 * pi / 12) * index;
                final offsetX = 100 * cos(angle + _controller.value * 2 * pi);
                final offsetY = 100 * sin(angle + _controller.value * 2 * pi);
                return Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Floating shimmer
              Positioned(
                top: -40,
                child: Opacity(
                  opacity: _glowAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}