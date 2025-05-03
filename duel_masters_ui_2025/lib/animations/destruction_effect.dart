import 'dart:math';
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
  late Animation<Color?> _glowColor;
  late Animation<Offset> _shakeOffset;

  bool _showExplosion = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.8,
      ),
    ]).animate(_controller);

    _opacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0)));

    _glowColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.redAccent.withOpacity(0.8),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
    );

    _shakeOffset = Tween(
      begin: Offset.zero,
      end: Offset(2.0, 2.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _showExplosion = true);
    });

    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _randomShake() {
    if (_controller.value > 0.3) return Offset.zero;
    // Random small shake offsets between -2 and +2 pixels
    return Offset(
      (_random.nextDouble() - 0.5) * 4,
      (_random.nextDouble() - 0.5) * 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showExplosion)
          SizedBox(
            width: 80,
            height: 80,
            child: GameWidget(
              game: ExplosionEffectGame(),
              backgroundBuilder: (_) => const SizedBox.shrink(),
            ),
          ),

        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _randomShake(),
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: _glowColor.value ?? Colors.transparent,
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: child,
                  ),
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
