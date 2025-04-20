import 'package:flutter/material.dart';
import '../../models/card_model.dart';

/// A dialog that lets the player select mana cards to pay for a summon.
class ManaSelectionDialog extends StatefulWidget {
  final CardModel cardToSummon;
  final List<CardModel> manaCards;
  final void Function(List<String> selectedIds) onConfirm;

  const ManaSelectionDialog({
    super.key,
    required this.cardToSummon,
    required this.manaCards,
    required this.onConfirm,
  });

  @override
  State<ManaSelectionDialog> createState() => _ManaSelectionDialogState();
}

class _ManaSelectionDialogState extends State<ManaSelectionDialog> {
  Set<CardModel> selectedManaCards = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        "You need ${widget.cardToSummon.manaCost} mana",
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        height: 120,
        width: double.maxFinite,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.manaCards.map((manaCard) {
              final isTapped = manaCard.tapped;
              final isSelected = selectedManaCards.contains(manaCard);

              return GestureDetector(
                onTap: isTapped
                    ? null
                    : () {
                  setState(() {
                    if (isSelected) {
                      selectedManaCards.remove(manaCard);
                    } else {
                      selectedManaCards.add(manaCard);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: EdgeInsets.all(isSelected ? 4 : 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.greenAccent : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                        : [],
                  ),
                  child: Transform.rotate(
                    angle: isTapped ? 3.14 / 2 : 0,
                    child: Opacity(
                      opacity: isTapped ? 0.4 : 1,
                      child: Image.asset(
                        manaCard.imagePath,
                        width: 80,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final selectedIds = selectedManaCards.map((c) => c.gameCardId).toList();
            Navigator.pop(context);
            widget.onConfirm(selectedIds);
          },
          child: const Text(
            "Summon",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      ],
    );
  }
}
