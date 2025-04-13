import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../screens/game_zone.dart';

class PlayerField extends StatelessWidget {
  final List<CardModel> hand;
  final List<CardModel> shields;
  final List<CardModel> manaZone;
  final List<CardModel> graveyard;
  final int deckSize;
  final Function(CardModel) onTapHandCard;
  final Function(CardModel) onSecondaryTapHandCard;
  final Function(CardModel) onSummonHandCard;        // NEW
  final Function(CardModel) onSendToManaHandCard;    // NEW
  final Function(CardModel) onTapManaCard;
  final VoidCallback onTapGraveyard;
  final bool playedMana;

  const PlayerField({
    super.key,
    required this.hand,
    required this.shields,
    required this.manaZone,
    required this.graveyard,
    required this.deckSize,
    required this.onTapHandCard,
    required this.onSecondaryTapHandCard,
    required this.onSummonHandCard,        // NEW
    required this.onSendToManaHandCard,    // NEW
    required this.onTapManaCard,
    required this.onTapGraveyard,
    required this.playedMana,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Empty left side to center shields
            SizedBox(width: 70), // adjust as needed for spacing

            // Shields in center
            _buildZoneContainer(
              label: "Your Shields",
              cards: shields,
              hideFaces: true,
            ),

            // Graveyard + Deck on right
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
                    Image.asset('assets/cards/0.jpg', width: 70),
                    Text('Your Deck ($deckSize)'),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildZoneContainer(
                label: "Your Hand",
                cards: hand,
                onTapCard: onTapHandCard,
                onSecondaryTapCard: onSecondaryTapHandCard,
                onAttack: onSummonHandCard,
                onSendToMana: onSendToManaHandCard,

              ),
            ),
            GestureDetector(
              child: _buildZoneContainer(
                label: "Your Mana",
                cards: manaZone,
                onTapCard: onTapManaCard,
              ),



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
    Function(CardModel)? onAttack,        // NEW
    Function(CardModel)? onSendToMana,        // NEW
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
        onAttack: onAttack,          // NEW
        onSendToMana: onSendToMana,      // NEW
        playedMana: playedMana,
      ),
    );
  }
}
