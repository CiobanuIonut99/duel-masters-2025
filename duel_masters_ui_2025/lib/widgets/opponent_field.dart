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

  final double cardWidth;

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
    this.cardWidth = 80,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _buildZoneContainer(
                label: "Opponent Hand",
                cards: hand,
                hideFaces: true,
              ),
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
                GestureDetector(
                  onTap: onTapManaZone,
                  child: _buildZoneContainer(
                    label: "Opponent Mana",
                    cards: manaZone,
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

        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    Function(CardModel)? onSendToMana,
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
        cardWidth: cardWidth,  // <<<< use it here
        hideCardFaces: hideFaces,
        allowManaAction: false,
        onTap: onTapCard,
        onSecondaryTap: onSecondaryTapCard,
        onAttack: onAttack,
        onSendToMana: onSendToMana,
      ),
    );
  }


}
