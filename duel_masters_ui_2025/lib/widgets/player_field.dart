import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../screens/game_zone.dart';
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
  final VoidCallback onTapManaZone;
  final VoidCallback onTapGraveyard;

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
    required this.onTapManaZone,
    required this.onTapGraveyard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildZoneContainer(
              label: "Your Shields",
              cards: shields,
              hideFaces: true,
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
                onSummonCard: onSummonHandCard,        // NEW
                onSendToMana: onSendToManaHandCard,    // NEW
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
                    label: "Your Mana",
                    cards: manaZone,
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
      ],
    );
  }

  Widget _buildZoneContainer({
    required String label,
    required List<CardModel> cards,
    bool hideFaces = false,
    Function(CardModel)? onTapCard,
    Function(CardModel)? onSecondaryTapCard,
    Function(CardModel)? onSummonCard,        // NEW
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
        onSummon: onSummonCard,          // NEW
        onSendToMana: onSendToMana,      // NEW
      ),
    );
  }
}
