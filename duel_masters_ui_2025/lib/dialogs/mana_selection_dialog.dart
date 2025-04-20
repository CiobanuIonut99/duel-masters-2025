import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';

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
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      content: StyledDialogContainer(
        borderColor: Colors.greenAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You need ${widget.cardToSummon.manaCost} mana",
              style: kDialogTitleStyle.copyWith(color: Colors.greenAccent),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap untapped mana cards to pay the cost.",
              style: kDialogSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
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
                          isSelected
                              ? selectedManaCards.remove(manaCard)
                              : selectedManaCards.add(manaCard);
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
            const SizedBox(height: 16),
            ConfirmButton(
              label: "Summon",
              icon: Icons.flash_on,
              color: Colors.greenAccent,
              onPressed: selectedManaCards.isNotEmpty
                  ? () {
                final selectedIds = selectedManaCards.map((c) => c.gameCardId).toList();
                Navigator.pop(context);
                widget.onConfirm(selectedIds);
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
