import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'styled_dialog_container.dart';

class DualCreatureListSelectionOverlay extends StatelessWidget {
  final List<CardModel> playerCreatures;
  final List<CardModel> opponentCreatures;
  final List<CardModel> selectedCreatures; // now a list
  final ValueChanged<CardModel> onCardToggle; // toggles selection
  final VoidCallback onConfirm;

  const DualCreatureListSelectionOverlay({
    super.key,
    required this.playerCreatures,
    required this.opponentCreatures,
    required this.selectedCreatures,
    required this.onCardToggle,
    required this.onConfirm,
  });

  Widget _buildCardRow(String title, List<CardModel> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kDialogSubtitleStyle),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cards.map((card) {
              final isSelected = selectedCreatures.any((c) => c.gameCardId == card.gameCardId);
              return GestureDetector(
                onTap: () => onCardToggle(card),
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
      ],
    );
  }

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
                  "Select up to 2 creatures to return to hand",
                  style: kDialogTitleStyle.copyWith(color: Colors.greenAccent),
                ),
                const SizedBox(height: 16),
                _buildCardRow("Your Creatures", playerCreatures),
                const SizedBox(height: 16),
                _buildCardRow("Opponent's Creatures", opponentCreatures),
                const SizedBox(height: 24),
                ConfirmButton(
                  label: "Confirm Selection",
                  icon: Icons.check_circle,
                  onPressed: selectedCreatures.isNotEmpty ? onConfirm : null,
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
