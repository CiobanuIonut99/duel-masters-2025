import 'package:flutter/material.dart';
import '../models/card_model.dart';

class HoverCardDetails extends StatefulWidget {
  final CardModel card;

  const HoverCardDetails({super.key, required this.card});

  @override
  State<HoverCardDetails> createState() => _HoverCardDetailsState();
}

class _HoverCardDetailsState extends State<HoverCardDetails> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(0.7),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _iconText(Icons.local_fire_department, '${widget.card.manaCost}', Colors.blueAccent),
                    SizedBox(width: 12),
                    _iconText(Icons.flash_on, '${widget.card.power}', Colors.redAccent),
                    SizedBox(width: 12),
                    _iconText(Icons.category, widget.card.type, Colors.amber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
