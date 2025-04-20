import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class CreatureSelectionOverlay extends StatelessWidget {
  final bool isMyCreature;
  final CardModel? shieldTriggerCard;
  final List<CardModel> opponentSelectableCreatures;
  final CardModel? selectedOpponentCreature;
  final ValueChanged<CardModel> onCardSelected;
  final VoidCallback onConfirm;

  const CreatureSelectionOverlay({
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
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orangeAccent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMyCreature
                      ? "Select a creature"
                      : "Opponent is selecting a creature from your battlezone to tap",
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  isMyCreature
                      ? "Choose one of the opponent's creatures to continue."
                      : "Waiting for opponent's move...",
                  style: const TextStyle(color: Colors.white70),
                ),
                if (isMyCreature && shieldTriggerCard?.ability != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      shieldTriggerCard!.ability!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
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
                              color: isSelected ? Colors.orangeAccent : Colors.transparent,
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
                  ElevatedButton.icon(
                    onPressed: selectedOpponentCreature != null ? onConfirm : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Confirm Selection"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
