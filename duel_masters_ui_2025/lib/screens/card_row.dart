import 'package:flutter/material.dart';
import '../models/card_model.dart';

/// CardRow Widget
///
/// Purpose:
/// - Renders a horizontal row of cards
/// - Handles card interactions like:
///   - Hover to scale
///   - Tap to preview or custom action
///   - Right-click (secondary tap) for custom action
///   - Optional rotation for tapped cards
///   - Optional hiding card faces
///
/// Common Usage:
/// - Player Hand
/// - Battle Zone
/// - Shield Zone
/// - Mana Zone
/// - Graveyard
///
class CardRow extends StatefulWidget {
  final List<CardModel> cards;
  final double cardWidth;
  final bool hideCardFaces;
  final bool rotate180;
  final bool allowManaAction;
  final String label;
  final Function(CardModel)? onTap;
  final Function(CardModel)? onSecondaryTap;
  final Set<String> glowingManaCardIds; // Accept glowingManaCardIds

  const CardRow({
    super.key,
    required this.cards,
    this.cardWidth = 60,
    this.hideCardFaces = false,
    this.rotate180 = false,
    this.allowManaAction = false,
    required this.label,
    this.onTap,
    this.onSecondaryTap,
    required this.glowingManaCardIds, // Pass glowingManaCardIds
  });

  @override
  State<CardRow> createState() => _CardRowState();
}

class _CardRowState extends State<CardRow> {
  CardModel? hoveredCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.cards.map((card) {
        // Check if the card is in the glowing set
        bool isGlowing = widget.glowingManaCardIds.contains(card.gameCardId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredCard = card),
            onExit: (_) => setState(() => hoveredCard = null),
            child: GestureDetector(
              onTap: () {
                if (widget.label == "Your Hand" && !card.name.contains("Shield")) {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            card.imagePath,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  widget.onTap?.call(card); // Parent-defined behavior
                }
              },
              onSecondaryTap: () {
                widget.onSecondaryTap?.call(card); // Right-click behavior
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  boxShadow: isGlowing
                      ? [
                    BoxShadow(color: Colors.cyanAccent, blurRadius: 15, spreadRadius: 2),
                  ]
                      : [],
                ),
                child: Transform.rotate(
                  angle: (card.isTapped ? -1.57 : 0) + (widget.rotate180 ? 3.14 : 0),
                  child: Transform.scale(
                    scale: hoveredCard == card ? 1.15 : 1.0, // Hover scaling
                    child: Image.asset(
                      widget.hideCardFaces ? 'assets/cards/0.jpg' : card.imagePath,
                      width: widget.cardWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
