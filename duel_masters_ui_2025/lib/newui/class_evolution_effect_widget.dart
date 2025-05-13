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
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRingColor() {
    return Color.lerp(Colors.amber, Colors.cyan, (_controller.value))!;
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
              // Pulsing background glow (smaller)
              Container(
                width: 140,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: colorGradient,
                ),
              ),

              // Rotating rune ring with dynamic color
              Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Container(
                  width: 160,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getRingColor().withOpacity(0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "✦ ✧ ✦",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.amberAccent.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),

              // Main card with glowing shadow + slight rotation
              Transform(
                transform: Matrix4.identity()
                  ..scale(1 + 0.05 * sin(_controller.value * pi * 2))
                  ..rotateZ(0.02 * sin(_controller.value * pi * 2)),
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Sparkles (fade in/out, smaller orbit)
              ...List.generate(12, (index) {
                final angle = (2 * pi / 12) * index;
                final offsetX = 80 * cos(angle + _controller.value * 2 * pi);
                final offsetY = 80 * sin(angle + _controller.value * 2 * pi);
                final sparkleOpacity =
                    0.5 + 0.5 * sin(_controller.value * 2 * pi + index);
                return Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Opacity(
                    opacity: sparkleOpacity,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              // Floating shimmer (smaller)
              Positioned(
                top: -30,
                child: Opacity(
                  opacity: _glowAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 30,
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
