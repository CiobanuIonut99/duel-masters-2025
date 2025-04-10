import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardRow extends StatefulWidget {
  final List<CardModel> cards;
  final double cardWidth;
  final bool hideCardFaces;
  final bool rotate180;
  final bool allowManaAction;
  final String label;
  final Function(CardModel)? onTap;
  final Function(CardModel)? onSecondaryTap;

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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredCard = card),
            onExit: (_) => setState(() => hoveredCard = null),
            child: GestureDetector(
              onTap: () {
                // Only full preview for hand
                if (widget.label == "Your Hand" && !card.name.startsWith("Shield")) {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(card.imagePath,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  widget.onTap?.call(card);
                }
              },
              onSecondaryTap: () {
                widget.onSecondaryTap?.call(card);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: const BoxDecoration(),
                child: Transform.rotate(
                  angle: (card.isTapped ? -1.57 : 0) + (widget.rotate180 ? 3.14 : 0),
                  child: Transform.scale(
                    scale: hoveredCard == card ? 1.15 : 1.0,
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
