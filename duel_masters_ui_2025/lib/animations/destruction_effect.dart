import 'package:flutter/material.dart';

class CreatureDestructionEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const CreatureDestructionEffect({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<CreatureDestructionEffect> createState() => _CreatureDestructionEffectState();
}

class _CreatureDestructionEffectState extends State<CreatureDestructionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
