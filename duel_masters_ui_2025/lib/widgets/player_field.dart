import 'package:duel_masters_ui_2025/widgets/zone_container.dart';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../screens/game_zone.dart';

/// The PlayerField widget is responsible for rendering
/// all of the current player's zones in the game field:
/// - Battle Zone
/// - Shields
/// - Graveyard
/// - Deck
/// - Hand
/// - Mana Zone
///
/// It delegates interactions like tapping, summoning,
/// attacking, and sending to mana to the parent widget via callbacks.
class PlayerField extends StatelessWidget {
  /// Player's cards in hand
  final List<CardModel> hand;

  /// Player's shield cards
  final List<CardModel> shields;

  /// Player's mana zone cards
  final List<CardModel> manaZone;

  /// Player's graveyard cards
  final List<CardModel> graveyard;

  /// Player's deck size (only size known)
  final int deckSize;

  /// Player's battle zone cards (creatures)
  final List<CardModel> playerBattleZone;

  /// Callbacks for card interactions
  final Function(CardModel) onTapHandCard;
  final Function(CardModel) onSummonHandCard;
  final Function(CardModel) onAttack;
  final Function(CardModel) onSendToManaHandCard;
  final Function(CardModel) onTapManaCard;
  final VoidCallback onTapGraveyard;

  /// Whether player has already sent a card to mana this turn
  final bool playedMana;
  final bool isMyTurn;

  const PlayerField({
    super.key,
    required this.hand,
    required this.shields,
    required this.manaZone,
    required this.graveyard,
    required this.deckSize,
    required this.onTapHandCard,
    required this.onTapManaCard,
    required this.onTapGraveyard,
    required this.onSummonHandCard,
    required this.onAttack,
    required this.onSendToManaHandCard,
    required this.playedMana,
    required this.isMyTurn,
    required this.playerBattleZone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1 → Battle Zone
        Container(
          constraints: BoxConstraints(minHeight: 100),
          width: double.infinity,
          child: _buildZoneContainer(
            label: "Your Battle Zone",
            cards: playerBattleZone,
            onAttack: onAttack,
            onTap: onTapHandCard
          ),
        ),

        SizedBox(height: 4),

        // Row 2 → Shields (centered), Graveyard & Deck (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 70), // Left spacing to balance layout
            _buildZoneContainer(
              label: "Your Shields",
              cards: shields,
              hideCardFaces: true, // Always hidden faces
            ),
            Row(
              children: [
                // Graveyard
                GestureDetector(
                  onTap: onTapGraveyard,
                  child: _buildZoneContainer(
                    label: "Graveyard",
                    cards: graveyard,
                  ),
                ),
                SizedBox(width: 8),
                // Deck
                Column(
                  children: [
                    Image.asset('assets/cards/0.jpg', width: 70),
                    Text('$deckSize'),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Row 3 → Hand (left) & Mana (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildZoneContainer(
                label: "Your Hand",
                cards: hand,
                onTap: onTapHandCard,
                onSummon: onSummonHandCard,
                onSendToMana: onSendToManaHandCard,
              ),
            ),
            GestureDetector(
              child: _buildZoneContainer(
                label: "Your Mana",
                cards: manaZone,
                onTap: onTapManaCard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Creates a standard zone UI with consistent styling.
  Widget _buildZoneContainer({
    required String label,
    required List<CardModel> cards,
    bool hideCardFaces = false,
    Function(CardModel)? onTap,
    Function(CardModel)? onSummon,
    Function(CardModel)? onAttack,
    Function(CardModel)? onSendToMana,
  }) {
    return ZoneContainer(
      label: label,
      borderColor: Colors.white24,
      child: GameZone(
        label: label,
        cards: cards,
        hideCardFaces: hideCardFaces,
        allowManaAction: false,
        onTap: onTap,
        onSummon: onSummon,
        onAttack: onAttack,
        onSendToMana: onSendToMana,
        playedMana: playedMana,
        isMyTurn: isMyTurn,
      ),
    );
  }


}
