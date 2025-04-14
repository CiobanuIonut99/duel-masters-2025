import 'package:duel_masters_ui_2025/widgets/zone_container.dart';
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
  final Function(CardModel) onSummonHandCard;        // NEW
  final Function(CardModel) onAttack;        // NEW
  final Function(CardModel) onSendToManaHandCard;    // NEW
  final Function(CardModel) onTapManaCard;
  final VoidCallback onTapGraveyard;
  final bool playedMana;
  final List<CardModel> playerBattleZone;

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
    required this.playerBattleZone,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 100,  // tweak this value if needed (depends on your card size)
          ),
          width: double.infinity, // optional for full width
          child: _buildZoneContainer(
            label: "Your Battle Zone",
            cards: playerBattleZone,
            onAttack: onAttack,
          ),
        ),


        SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 70),
            _buildZoneContainer(
              label: "Your Shields",
              cards: shields,
              hideCardFaces: true,
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
                    Image.asset('assets/cards/0.jpg', width: 70),
                    Text('Your Deck ($deckSize)'),
                  ],
                ),
              ],
            ),
          ],
        ),

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
      ),
    );
  }


}
