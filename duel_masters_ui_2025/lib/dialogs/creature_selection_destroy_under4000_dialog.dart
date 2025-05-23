import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class DestroyCreatureUnder4000SelectionOverlay extends StatelessWidget {
  final bool isMyCreature;
  final CardModel? shieldTriggerCard;
  final List<CardModel> opponentUnder4000Creatures;
  final CardModel? selectedOpponentCreature;
  final ValueChanged<CardModel> onCardSelected;
  final VoidCallback onConfirm;

  const DestroyCreatureUnder4000SelectionOverlay({
    super.key,
    required this.isMyCreature,
    required this.shieldTriggerCard,
    required this.opponentUnder4000Creatures,
    required this.selectedOpponentCreature,
    required this.onCardSelected,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: StyledDialogContainer(
            borderColor: Colors.greenAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMyCreature
                      ? "Select a creature with power under 4000 to destroy"
                      : "Opponent is selecting a creature from your battlezone to destroy",
                  style: kDialogTitleStyle.copyWith(color: Colors.greenAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  isMyCreature
                      ? "Choose one of the opponent's creatures to continue."
                      : "Opponent must choose one of your creatures to destroy",
                  style: kDialogSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
                if (isMyCreature && shieldTriggerCard?.ability != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      shieldTriggerCard!.ability!,
                      textAlign: TextAlign.center,
                      style: kDialogAbilityStyle,
                    ),
                  ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: opponentUnder4000Creatures.map((card) {
                      final isSelected = selectedOpponentCreature?.gameCardId == card.gameCardId;
                      return GestureDetector(
                        onTap: isMyCreature ? () => onCardSelected(card) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: EdgeInsets.all(isSelected ? 4 : 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.greenAccent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Image.asset(card.imagePath, width: 80),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (isMyCreature)
                  ConfirmButton(
                    label: "Confirm Selection",
                    icon: Icons.check_circle,
                    onPressed: selectedOpponentCreature != null ? onConfirm : null,
                    color: Colors.greenAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
