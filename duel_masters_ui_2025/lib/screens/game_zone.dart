import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'card_row.dart';

class GameZone extends StatelessWidget {
  final String label;
  final List<CardModel> cards;
  final double cardWidth;
  final bool hideCardFaces;
  final bool rotate180;
  final bool scrollable;
  final bool allowManaAction;
  final Function(CardModel)? onTap;
  final Function(CardModel)? onSecondaryTap;

  const GameZone({
    super.key,
    required this.label,
    required this.cards,
    this.cardWidth = 60,
    this.hideCardFaces = false,
    this.rotate180 = false,
    this.scrollable = false,
    this.allowManaAction = false,
    this.onTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = CardRow(
      cards: cards,
      cardWidth: cardWidth,
      hideCardFaces: hideCardFaces,
      rotate180: rotate180,
      allowManaAction: allowManaAction,
      label: label,
      onTap: onTap,
      onSecondaryTap: onSecondaryTap,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: scrollable
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: content,
          )
              : content,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
