import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../screens/game_zone.dart';
import 'zone_container.dart';

class OpponentField extends StatelessWidget {
  final List<CardModel> hand;
  final List<CardModel> shields;
  final List<CardModel> manaZone;
  final List<CardModel> graveyard;
  final int deckSize;
  final List<CardModel> opponentBattleZone;
  final bool isSelectingAttackTarget;
  final CardModel? selectedAttacker;
  final VoidCallback onTapManaZone;
  final Function(CardModel) onAttack;
  final Function(CardModel) onConfirmAttack;
  final VoidCallback onTapGraveyard;
  final Set<String> glowAttackableShields;
  final Set<String> glowAttackableCreatures;

  const OpponentField({
    super.key,
    required this.hand,
    required this.shields,
    required this.manaZone,
    required this.graveyard,
    required this.onAttack,
    required this.onConfirmAttack,
    required this.deckSize,
    required this.opponentBattleZone,
    required this.isSelectingAttackTarget,
    required this.selectedAttacker,
    required this.onTapManaZone,
    required this.onTapGraveyard,
    required this.glowAttackableShields,
    required this.glowAttackableCreatures,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Opponent Mana | (spacer) | Opponent Hand
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onTapManaZone,
              child: _buildZoneContainer(
                label: "Opponent Mana",
                cards: manaZone,
              ),
            ),
            SizedBox(width: 50), // empty center space
            _buildZoneContainer(
              label: "Opponent Hand",
              cards: hand,
              hideCardFaces: true,
            ),
          ],
        ),

        SizedBox(height: 4),

        // Row 2: Deck + Graveyard | Centered Shields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Transform.rotate(
                      angle: 3.14,
                      child: Image.asset('assets/cards/0.jpg', width: 70),
                    ),
                    Text('Opponent Deck ($deckSize)'),
                  ],
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: onTapGraveyard,
                  child: _buildZoneContainer(
                    label: "Graveyard",
                    cards: graveyard,
                  ),
                ),
              ],
            ),
            _buildZoneContainer(
              label: "Opponent Shields",
              cards: shields,
              hideCardFaces: true,
              onSecondaryTap: (shield) {
                if (isSelectingAttackTarget && selectedAttacker != null) {
                }
              },
            ),
            SizedBox(width: 70), // balance row width
          ],
        ),

        SizedBox(height: 4),

        // Row 3: Opponent Battle Zone (same width as player)
        Container(
          constraints: BoxConstraints(minHeight: 100),
          width: double.infinity,
          child: _buildZoneContainer(
            label: "Opponent Battle Zone",
            cards: opponentBattleZone,
            onAttack: onAttack
          ),
        ),
      ],
    );
  }

  Widget _buildZoneContainer({
    required String label,
    required List<CardModel> cards,
    bool hideCardFaces = false,
    Function(CardModel)? onTap,
    Function(CardModel)? onSecondaryTap,
    Function(CardModel)? onSummon,
    Function(CardModel)? onAttack,
    Function(CardModel)? onConfirmAttack,
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
        onSecondaryTap: onSecondaryTap,
        onSummon: onSummon,
        onAttack: onAttack,
        onConfirmAttack: onConfirmAttack,
        onSendToMana: onSendToMana,
        glowingManaCardIds: (label == "Opponent Shields")
            ? glowAttackableShields
            : (label == "Opponent Battle Zone")
            ? glowAttackableCreatures
            : {},

      ),
    );
  }

}
