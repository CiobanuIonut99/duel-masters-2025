import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  final Function(CardModel)? onAttack;          // Sword
  final Function(CardModel)? onSendToMana;      // Bolt
  final Function(CardModel)? onConfirmAttack;      // Bolt
  final Set<String> glowingManaCardIds;
  final Set<String> glowAttackableCreatures;
  final bool playedMana;

  const CardRow({
    super.key,
    required this.label,
    required this.cards,
    required this.hideCardFaces,
    required this.allowManaAction,
    this.onTap,
    this.onSecondaryTap,
    this.onSummon,
    this.onAttack,
    this.onSendToMana,
    this.onConfirmAttack,
    required this.playedMana,
    this.cardWidth = 60,
    required this.rotate180,
    required this.glowingManaCardIds,
    required this.glowAttackableCreatures,
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
        bool isGlowing = widget.glowingManaCardIds.contains(card.gameCardId)
            || widget.glowAttackableCreatures.contains(card.gameCardId);


        return Padding(
          padding: EdgeInsets.symmetric(horizontal: card.tapped ? 16 : 8),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredCard = card),
            onExit: (_) => setState(() => hoveredCard = null),
            child: GestureDetector(
              onTap: () {
                // Always allow tap to enlarge except for opponent zones
                if (!widget.hideCardFaces) {
                  widget.onTap?.call(card);
                }
              },


              onSecondaryTap: () => widget.onSecondaryTap?.call(card),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: widget.cardWidth,
                    height: widget.cardWidth * 1.4,
                    decoration: BoxDecoration(
                      boxShadow: isGlowing
                          ? [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],

                      borderRadius: card.tapped ? BorderRadius.circular(8) : BorderRadius.zero,
                    ),
                    child: Transform.rotate(
                      angle: (card.tapped ? -math.pi / 2 : 0) + (widget.rotate180 ? math.pi : 0),
                      child: Transform.scale(
                        scale: hoveredCard == card ? 1.15 : card.tapped ? 0.85 : 1.0,
                        child: Image.asset(
                          widget.hideCardFaces ? 'assets/cards/0.jpg' : card.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                    if (hoveredCard == card && widget.label == "Your Hand")
                      Positioned(
                        bottom: -10,
                        child: Row(
                          children: [
                            if (card.summonable)
                              _actionButton(
                                icon: LucideIcons.flame,
                                color: Colors.redAccent,
                                onPressed: () => widget.onSummon?.call(card),
                              ),
                            if(!widget.playedMana)
                            _actionButton(
                              icon: Icons.bolt,
                              color: Colors.blueAccent,
                              onPressed: () => widget.onSendToMana?.call(card),
                            ),
                          ],
                        ),
                      ),


                  if (hoveredCard == card &&
                      widget.label == "Your Battle Zone" &&
                      !card.tapped && card.canAttack)
                    Positioned(
                      bottom: -10,
                      child:
                      _actionButton(
                        icon: LucideIcons.crosshair,
                        color: Colors.redAccent,
                        onPressed: () => widget.onAttack?.call(card), // or attack callback
                      ),
                    ),

                  if (hoveredCard == card && isGlowing)
                    Positioned(
                      bottom: -10,
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.sword,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () => widget.onConfirmAttack?.call(card),
                        splashRadius: 24,
                        tooltip: 'Attack',
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

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.black.withOpacity(0.8),
        shape: const CircleBorder(),
        elevation: 4,
        child: IconButton(
          icon: Icon(icon, color: color, size: 26),
          onPressed: onPressed,
          splashRadius: 24,
        ),
      ),
    );
  }



}
