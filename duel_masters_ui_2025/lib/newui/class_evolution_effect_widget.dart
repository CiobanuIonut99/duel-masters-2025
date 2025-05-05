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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
          double angle = _controller.value * 2 * pi;
          double pulse = 1 + 0.05 * sin(angle * 4);
          double glowOpacity = 0.6 + 0.4 * sin(angle * 2);

          return Transform.scale(
            scale: pulse,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Outer pulsing ripple rings
                for (int i = 1; i <= 3; i++)
                  Container(
                    width: 160.0 * i * pulse,
                    height: 220.0 * i * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.2 / i),
                        width: 2,
                      ),
                    ),
                  ),

                // Rotating spark particles
                for (int i = 0; i < 8; i++)
                  Transform.translate(
                    offset: Offset(
                      100 * cos(angle + i * pi / 4),
                      130 * sin(angle + i * pi / 4),
                    ),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.7),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main card with animated shadow and flame aura
                Container(
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
                        color: Colors.orangeAccent.withOpacity(glowOpacity),
                        blurRadius: 40,
                        spreadRadius: 18,
                      ),
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(glowOpacity * 0.6),
                        blurRadius: 60,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),

                // Sweeping shimmer overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: ShimmerPainter(_controller.value),
                  ),
                ),

                // Floating sparkle top icon
                Positioned(
                  top: -40,
                  child: Opacity(
                    opacity: glowOpacity,
                    child: Icon(
                      Icons.local_fire_department,
                      size: 40,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Shimmer painter sweeps a beam across the card
class ShimmerPainter extends CustomPainter {
  final double progress;

  ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerWidth = size.width * 0.2;
    final shimmerPosition = size.width * progress;

    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.6),
        Colors.transparent,
      ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment(-1.0 + 2 * progress, -1.0),
      end: Alignment(-1.0 + 2 * progress, 1.0),
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(shimmerPosition, 0, shimmerWidth, size.height),
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
