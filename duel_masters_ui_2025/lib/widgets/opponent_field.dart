import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../screens/game_zone.dart';

class OpponentField extends StatelessWidget {
  final List<CardModel> hand;
  final List<CardModel> shields;
  final List<CardModel> manaZone;
  final List<CardModel> graveyard;
  final int deckSize;
  final bool isSelectingAttackTarget;
  final CardModel? selectedAttacker;
  final Function(CardModel attacker, CardModel shield) onShieldAttack;
  final VoidCallback onTapManaZone;
  final VoidCallback onTapGraveyard;
  final Set<String> glowAttackableShields;

  const OpponentField({
    super.key,
    required this.hand,
    required this.shields,
    required this.manaZone,
    required this.graveyard,
    required this.deckSize,
    required this.isSelectingAttackTarget,
    required this.selectedAttacker,
    required this.onShieldAttack,
    required this.onTapManaZone,
    required this.onTapGraveyard,
    required this.glowAttackableShields,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildZoneContainer(
              label: "Opponent Hand",
              cards: hand,
              hideFaces: true,
            ),
            GestureDetector(
              onTap: onTapManaZone,
              child: _buildZoneContainer(
                label: "Opponent Mana",
                cards: manaZone,
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Row 2 → Empty left | Shields center | Deck + Graveyard right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 70),

            _buildZoneContainer(
              label: "Opponent Shields",
              cards: shields,
              hideFaces: true,
              onSecondaryTapCard: (shield) {
                if (isSelectingAttackTarget && selectedAttacker != null) {
                  onShieldAttack(selectedAttacker!, shield);
                }
              },
            ),

            Row(
              children: [
                GestureDetector(
                  onTap: onTapGraveyard,
                  child: _buildZoneContainer(
                    label: "Graveyard",
                    cards: graveyard,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    Transform.rotate(
                      angle: 3.14,
                      child: Image.asset('assets/cards/0.jpg', width: 70),
                    ),
                    Text('Opponent Deck ($deckSize)'),
                  ],
                ),
              ],
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildZoneContainer({
    required String label,
    required List<CardModel> cards,
    bool hideFaces = false,
    Function(CardModel)? onTapCard,
    Function(CardModel)? onSecondaryTapCard,
    Function(CardModel)? onAttack,
    Function(CardModel)? onSendToManaCard,
  }) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GameZone(
        label: label,
        cards: cards,
        cardWidth: 100,
        hideCardFaces: hideFaces,
        allowManaAction: false,
        onTap: onTapCard,
        onSecondaryTap: onSecondaryTapCard,
        onAttack: onAttack,
        onSendToMana: onSendToManaCard,
        glowingManaCardIds: label == "Opponent Shields" ? glowAttackableShields : {},
      ),
    );
  }
}
