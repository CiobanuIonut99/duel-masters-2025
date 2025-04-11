import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardRow extends StatefulWidget {
  final List<CardModel> cards;
  final double cardWidth;
  final bool hideCardFaces;
  final bool rotate180;
  final bool allowManaAction;
  final String label;
  final Function(CardModel)? onTap;             // Enlarge
  final Function(CardModel)? onSecondaryTap;    // Right-click (optional fallback)
  final Function(CardModel)? onSummon;          // Sword
  final Function(CardModel)? onSendToMana;      // Bolt
  final Set<String> glowingManaCardIds;

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
    this.onSummon,
    this.onSendToMana,
    required this.glowingManaCardIds,
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
        bool isGlowing = widget.glowingManaCardIds.contains(card.gameCardId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredCard = card),
            onExit: (_) => setState(() => hoveredCard = null),
            child: GestureDetector(
              onTap: () => widget.onTap?.call(card),
              onSecondaryTap: () => widget.onSecondaryTap?.call(card),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      boxShadow: isGlowing
                          ? [BoxShadow(color: Colors.cyanAccent, blurRadius: 15, spreadRadius: 2)]
                          : [],
                    ),
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

                  if (hoveredCard?.gameCardId == card.gameCardId && widget.label == "Your Hand")
                    Positioned(
                      bottom: 0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility, color: Colors.white),
                            onPressed: () => widget.onTap?.call(card),
                          ),
                          if(card.isSummonable)
                          IconButton(
                            icon: Icon(Icons.sports, color: Colors.redAccent),
                            onPressed: () => widget.onSummon?.call(card),
                          ),
                          IconButton(
                            icon: Icon(Icons.bolt, color: Colors.blueAccent),
                            onPressed: () => widget.onSendToMana?.call(card),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
