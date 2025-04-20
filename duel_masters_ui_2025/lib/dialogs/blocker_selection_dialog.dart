import 'package:flutter/material.dart';
import '../../models/card_model.dart';

/// A dialog for selecting a blocker when defending an attack.
class BlockerSelectionDialog extends StatefulWidget {
  final List<CardModel> blockers;
  final void Function(CardModel selected) onConfirm;
  final void Function() onSkip;

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
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.7),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.yellowAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Do you want to block this attack?",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              "If yes, choose a blocker below. If no, press the button to let the attack go through.",
              style: TextStyle(color: Colors.white70),
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
                          color: isSelected ? Colors.yellowAccent : Colors.transparent,
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
            ElevatedButton.icon(
              onPressed: selectedBlocker != null
                  ? () {
                Navigator.pop(context);
                widget.onConfirm(selectedBlocker!);
              }
                  : null,
              icon: const Icon(Icons.shield),
              label: const Text("Confirm Blocker"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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
      ),
    );
  }
}