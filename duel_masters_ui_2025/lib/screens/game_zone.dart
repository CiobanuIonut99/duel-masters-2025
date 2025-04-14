import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'card_row.dart';

/// GameZone Widget
///
/// Reusable, pure layout widget for any card zone:
/// (Hand, Mana, Shields, Battle Zone, Graveyard, Deck visual)
///
/// Does NOT handle any logic.
/// Does NOT style with background or borders (that's Field's job).
///
/// Responsibilities:
/// - Renders cards in a row (via CardRow)
/// - Supports optional horizontal scrolling
/// - Passes card interaction callbacks down to CardRow
/// - Accepts glow / highlight states for specific cards
///
/// Usage:
/// GameZone is a visual wrapper only.
/// Think of it like a clean lane of cards.

class GameZone extends StatelessWidget {
  /// Zone label (example: "Your Hand", "Opponent Mana")
  final String label;

  /// Cards to display in the zone
  final List<CardModel> cards;

  /// Glowing IDs → Green glow (used for mana selection / shields / targets)
  final Set<String> glowingManaCardIds;

  /// Glowing IDs → Green glow (used for attackable creatures)
  final Set<String> glowAttackableCreatures;

  /// Width of each card
  final double cardWidth;

  /// Whether to hide card faces (example: Opponent Hand, Shields)
  final bool hideCardFaces;

  /// Flip cards 180° (used for opponent zones)
  final bool rotate180;

  /// Whether the row should scroll horizontally (true for Hand usually)
  final bool scrollable;

  /// Whether to allow sending cards to mana (mainly for Hand)
  final bool allowManaAction;

  /// Interaction Callbacks
  final Function(CardModel)? onTap;            // Enlarge
  final Function(CardModel)? onSummon;         // Summon Creature
  final Function(CardModel)? onAttack;         // Start Attack
  final Function(CardModel)? onSendToMana;     // Send to Mana
  final Function(CardModel)? onConfirmAttack;  // Confirm Target Attack

  /// Whether player already played a mana this turn
  final bool playedMana;

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
    this.onSummon,
    this.onAttack,
    this.onSendToMana,
    this.onConfirmAttack,
    this.glowingManaCardIds = const {},
    this.glowAttackableCreatures = const {},
    this.playedMana = false,
  });

  @override
  Widget build(BuildContext context) {
    // The actual row of cards
    final content = CardRow(
      label: label,
      cards: cards,
      hideCardFaces: hideCardFaces,
      allowManaAction: allowManaAction,
      onTap: onTap,
      onSummon: onSummon,
      onAttack: onAttack,
      onSendToMana: onSendToMana,
      onConfirmAttack: onConfirmAttack,
      playedMana: playedMana,
      cardWidth: cardWidth,
      rotate180: rotate180,
      glowingManaCardIds: glowingManaCardIds,
      glowAttackableCreatures: glowAttackableCreatures,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Either scrollable or fixed row
        scrollable
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: content,
        )
            : content,

        const SizedBox(height: 4),

        // Zone Label Text
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
