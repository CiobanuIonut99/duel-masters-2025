import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../models/card_model.dart';

class TremblingShield extends StatefulWidget {
  final CardModel card;
  final VoidCallback onCompleted;

  const TremblingShield({
    required this.card,
    required this.onCompleted,
    Key? key,
  }) : super(key: key);

  @override
  State<TremblingShield> createState() => _TremblingShieldState();
}

class _TremblingShieldState extends State<TremblingShield>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _trembleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _trembleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _controller.repeat(reverse: true);

    // End tremble and trigger slide to hand
    Future.delayed(Duration(milliseconds: 1200), () {
      _controller.stop();
      widget.onCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _trembleAnimation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(_trembleAnimation.value, 0),
          child: child,
        );
      },
      child: Center(
        child: Image.asset(widget.card.imagePath, width: 120),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
