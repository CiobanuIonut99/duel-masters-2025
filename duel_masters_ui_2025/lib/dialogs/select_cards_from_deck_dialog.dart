import 'package:flutter/material.dart';
import '../models/card_model.dart';

class SelectCardsFromDeckDialog extends StatefulWidget {
  final List<CardModel> deck;
  final int maxSelection;
  final int minSelection;
  final void Function(List<String> selectedIds) onConfirm;

  const SelectCardsFromDeckDialog({
    super.key,
    required this.deck,
    this.maxSelection = 2,
    this.minSelection = 1,
    required this.onConfirm,
  });

  @override
  State<SelectCardsFromDeckDialog> createState() => _SelectCardsFromDeckDialogState();
}

class _SelectCardsFromDeckDialogState extends State<SelectCardsFromDeckDialog> {
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
              "Select at least 1 card",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 12),
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
                          if (isSelected) {
                            selectedCardIds.remove(card.gameCardId);
                          } else if (selectedCardIds.length < widget.maxSelection) {
                            selectedCardIds.add(card.gameCardId);
                          }
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
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: (selectedCardIds.length >= widget.minSelection &&
                  selectedCardIds.length <= widget.maxSelection)
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
