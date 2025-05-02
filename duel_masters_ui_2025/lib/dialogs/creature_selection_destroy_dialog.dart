import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class DestroyCreatureSelectionOverlay extends StatelessWidget {
  final bool isMyCreature;
  final CardModel? shieldTriggerCard;
  final List<CardModel> opponentSelectableCreatures;
  final CardModel? selectedOpponentCreature;
  final ValueChanged<CardModel> onCardSelected;
  final VoidCallback onConfirm;

  const DestroyCreatureSelectionOverlay({
    super.key,
    required this.isMyCreature,
    required this.shieldTriggerCard,
    required this.opponentSelectableCreatures,
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
                      ? "Select a creature"
                      : "Opponent is selecting a creature from your battlezone to tap",
                  style: kDialogTitleStyle.copyWith(color: Colors.greenAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  isMyCreature
                      ? "Choose one of the opponent's creatures to continue."
                      : "Waiting for opponent's move...",
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
                    children: opponentSelectableCreatures.map((card) {
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
