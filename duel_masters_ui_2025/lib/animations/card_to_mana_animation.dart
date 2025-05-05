import 'package:flutter/material.dart';

class CardToManaAnimation extends StatefulWidget {
  final Widget cardWidget;
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onCompleted;

  const CardToManaAnimation({
    super.key,
    required this.cardWidget,
    required this.startOffset,
    required this.endOffset,
    required this.onCompleted,
  });

  @override
  State<CardToManaAnimation> createState() => _CardToManaAnimationState();
}

class _CardToManaAnimationState extends State<CardToManaAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) {
      widget.onCompleted();
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
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.cardWidget,
          ),
        );
      },
    );
  }
}
