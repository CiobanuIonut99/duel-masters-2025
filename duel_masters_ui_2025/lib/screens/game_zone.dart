import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'card_row.dart';

/// GameZone Widget
///
/// Purpose:
/// - Visual container for any card zone in the game
/// - Handles:
///   - Label rendering
///   - Layout & padding
///   - Optional horizontal scroll
///   - Passing interaction logic to CardRow
///
/// Typical Usage:
/// - Hand
/// - Mana Zone
/// - Shields
/// - Graveyard
/// - Battle Zone
///
/// Always renders:
/// - Cards via CardRow
/// - Zone label below

class GameZone extends StatelessWidget {
  /// Name of the zone (displayed as label below cards)
  final String label;

  /// Cards to display in the zone
  final List<CardModel> cards;

  /// Width of each card (default 60)
  final double cardWidth;

  /// Hide faces of the cards? (true → shows back of cards)
  final bool hideCardFaces;

  /// Rotate 180 degrees (for opponent zones)
  final bool rotate180;

  /// Make the zone horizontally scrollable? (true → scroll enabled)
  final bool scrollable;

  /// Not directly used here but passed to CardRow (used for glow or special styling)
  final bool allowManaAction;

  /// Left-click behavior per card
  final Function(CardModel)? onTap;

  /// Right-click behavior per card
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
    /// Core content = CardRow → builds the actual cards
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
        /// Cards container (background, rounded, padding)
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

        /// Label below the zone
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
