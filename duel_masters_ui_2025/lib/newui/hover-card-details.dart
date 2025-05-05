import 'package:flutter/material.dart';
import '../models/card_model.dart';

class HoverCardDetails extends StatelessWidget {
  final CardModel card;

  const HoverCardDetails({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(8),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card.name,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Colors.blueAccent, size: 16),
                SizedBox(width: 4),
                Text('Mana: ${card.manaCost}', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.whatshot, color: Colors.redAccent, size: 16),
                SizedBox(width: 4),
                Text('Power: ${card.power}', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(card.type, style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
