import 'package:duel_masters_ui_2025/dialogs/styled_dialog_container.dart';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class BlockerSelectionDialog extends StatefulWidget {
  final List<CardModel> blockers;
  final void Function(CardModel selected) onConfirm;
  final VoidCallback onSkip;

  const BlockerSelectionDialog({
    super.key,
    required this.blockers,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  State<BlockerSelectionDialog> createState() => _BlockerSelectionDialogState();
}

class _BlockerSelectionDialogState extends State<BlockerSelectionDialog> {
  CardModel? selectedBlocker;

  @override
  Widget build(BuildContext context) {
    return StyledDialogContainer(
      borderColor: Colors.greenAccent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Do you want to block this attack?", style: kDialogTitleStyle),
          const SizedBox(height: 8),
          const Text(
            "If yes, choose a blocker below. If no, press the button to let the attack go through.",
            style: kDialogSubtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.blockers.map((card) {
                final isSelected = selectedBlocker?.gameCardId == card.gameCardId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBlocker = card;
                    });
                  },
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
          ConfirmButton(
            label: "Confirm Blocker",
            icon: Icons.shield,
            onPressed: selectedBlocker != null
                ? () {
              Navigator.pop(context);
              widget.onConfirm(selectedBlocker!);
            }
                : null,
            color: Colors.greenAccent,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSkip();
            },
            child: const Text(
              "Don't block this time",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
