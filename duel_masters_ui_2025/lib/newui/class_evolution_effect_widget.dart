import 'package:flutter/material.dart';

class EnhancedEvolutionEffect extends StatefulWidget {
  final String cardImagePath;

  const EnhancedEvolutionEffect({super.key, required this.cardImagePath});

  @override
  State<EnhancedEvolutionEffect> createState() => _EnhancedEvolutionEffectState();
}

class _EnhancedEvolutionEffectState extends State<EnhancedEvolutionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

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
              Color.lerp(Colors.orange, Colors.red, _colorAnimation.value)!,
              Colors.transparent,
            ],
            radius: 0.8,
          );

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pulsing glow background
              Container(
                width: 160,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: colorGradient,
                ),
              ),

              // Main card with animated shadow
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
                      color: Color.lerp(
                          Colors.orangeAccent,
                          Colors.redAccent,
                          _colorAnimation.value)!
                          .withOpacity(_glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),

              // Rotating spark effect
              Transform.rotate(
                angle: _controller.value * 6.28, // full circle
                child: Container(
                  width: 180,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Floating shimmer overlay
              Positioned(
                top: -30,
                child: Opacity(
                  opacity: _glowAnimation.value,
                  child: Icon(
                    Icons.star,
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
