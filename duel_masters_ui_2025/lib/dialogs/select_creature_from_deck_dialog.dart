import 'package:flutter/material.dart';
import '../models/card_model.dart';

class SelectCreatureFromDeckDialog extends StatefulWidget {
  final bool isMyCreature;
  final List<CardModel> deck;
  final void Function(List<String> selectedIds) onConfirm;

  const SelectCreatureFromDeckDialog({
    super.key,
    required this.isMyCreature,
    required this.deck,
    required this.onConfirm,
  });

  @override
  State<SelectCreatureFromDeckDialog> createState() =>
      _SelectCreatureFromDeckDialogState();
}

class _SelectCreatureFromDeckDialogState extends State<SelectCreatureFromDeckDialog> {
  final Set<String> selectedCardIds = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isMyCreature
                  ? "Select a creature from your deck"
                  : "Opponent is choosing a creature from their deck",
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (widget.isMyCreature)
              Container(
                height: 400,
                width: 500,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.deck.map((card) {
                      final isSelected = selectedCardIds.contains(card.gameCardId);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCardIds.clear(); // allow only one selection
                            selectedCardIds.add(card.gameCardId);
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Image.asset(card.imagePath, width: 100),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(Icons.check_circle, color: Colors.blueAccent),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Waiting for opponent to choose a creature...",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            if (widget.isMyCreature)
              ElevatedButton(
                onPressed: selectedCardIds.length == 1
                    ? () {
                  Navigator.pop(context);
                  widget.onConfirm(selectedCardIds.toList());
                }
                    : null,
                child: Text("Confirm"),
              ),
          ],
        ),
      ),
    );
  }
}
