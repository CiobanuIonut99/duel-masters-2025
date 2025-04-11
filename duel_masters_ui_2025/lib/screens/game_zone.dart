import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'card_row.dart';

/// GameZone Widget
///
/// Pure Card Container for any zone.
/// Handles:
/// - Cards Layout (via CardRow)
/// - Optional Horizontal Scroll
///
/// Styling like background, padding, shadows → belongs to parent (Field).

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
        scrollable
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: content,
        )
            : content,

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
