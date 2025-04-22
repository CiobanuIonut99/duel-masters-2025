import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'explosion_effect_game.dart';

class CreatureDestructionEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const CreatureDestructionEffect({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<CreatureDestructionEffect> createState() =>
      _CreatureDestructionEffectState();
}

class _CreatureDestructionEffectState extends State<CreatureDestructionEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  bool _showExplosion = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));
    _opacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() => _showExplosion = true);
    });

    _controller.forward().whenComplete(() {
      if (widget.onComplete != null) widget.onComplete!();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showExplosion)
          if (_showExplosion)
            SizedBox(
              width: 80,
              height: 80,
              child: GameWidget(
                game: ExplosionEffectGame(),
                backgroundBuilder: (context) => Container(), // Transparent background
              ),
            ),

        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (_controller.value < 0.3)
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}
