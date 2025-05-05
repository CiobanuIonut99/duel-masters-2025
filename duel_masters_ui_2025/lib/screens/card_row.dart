import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../animations/destruction_effect.dart';
import '../models/card_model.dart';
import '../newui/class_evolution_effect_widget.dart';
import '../newui/hover-card-details.dart';

class CardRow extends StatefulWidget {
  final List<CardModel> cards;
  final double cardWidth;
  final bool hideCardFaces;
  final bool rotate180;
  final bool allowManaAction;
  final String label;
  final Function(CardModel)? onTap;
  final Function(CardModel)? onSummon;
  final Function(CardModel)? onAttack;
  final Function(CardModel)? onSendToMana;
  final Function(CardModel)? onConfirmAttack;
  final Set<String> glowingManaCardIds;
  final Set<String> glowAttackableCreatures;
  final bool playedMana;
  final bool isMyTurn;

  const CardRow({
    super.key,
    required this.label,
    required this.cards,
    required this.hideCardFaces,
    required this.allowManaAction,
    this.onTap,
    this.onSummon,
    this.onAttack,
    this.onSendToMana,
    this.onConfirmAttack,
    required this.playedMana,
    required this.isMyTurn,
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
    // Special: graveyard shows only tombstone + count
    if (widget.label == "Graveyard" || widget.label == "Opponent Graveyard") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/tombstone.png',
            width: widget.cardWidth,
            height: widget.cardWidth * 1.4,
          ),
          SizedBox(height: 4),
          Text(
            '${widget.cards.length} cards',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      );
    }

    // Default horizontal layout for other zones
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.cards.map((card) => _buildCardWidget(card)).toList(),
    );
  }

  Widget _buildCardWidget(CardModel card) {
    bool isGlowing =
        widget.glowingManaCardIds.contains(card.gameCardId) ||
        widget.glowAttackableCreatures.contains(card.gameCardId);

    final cardWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: card.tapped ? 16 : 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredCard = card),
        onExit: (_) => setState(() => hoveredCard = null),
        child: GestureDetector(
          onTap: () {
            if (isGlowing) {
              widget.onConfirmAttack?.call(card);
            } else if (!widget.hideCardFaces) {
              widget.onTap?.call(card);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Outer container only for the shadow
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 4,
                      offset: Offset(4, 8),
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: widget.cardWidth,
                  height: widget.cardWidth * 1.4,
                  // REMOVE boxShadow from here!
                  child: Transform.rotate(
                    angle:
                        (card.tapped ? -math.pi / 2 : 0) +
                        (widget.rotate180 ? math.pi : 0),
                    child: Transform.scale(
                      scale:
                          hoveredCard == card
                              ? 1.15
                              : (card.tapped ? 0.85 : 1.0),
                      child: Image.asset(
                        widget.hideCardFaces
                            ? 'assets/cards/0.jpg'
                            : card.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              if (hoveredCard == card)
                Positioned(
                  top: -80, // adjust position as needed
                  child: HoverCardDetails(card: card),
                ),
              if (hoveredCard == card &&
                  widget.label == "Your Hand" &&
                  widget.isMyTurn)
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
                      if (!widget.playedMana)
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
                  !card.tapped &&
                  card.canAttack &&
                  widget.isMyTurn)
                Positioned(
                  bottom: -10,
                  child: Column(
                    children: [
                      Text(
                        "Attack",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.swords,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () => widget.onAttack?.call(card),
                        splashRadius: 24,
                        tooltip: 'Choose target',
                      ),
                    ],
                  ),
                ),

              if (hoveredCard == card && isGlowing)
                Positioned(
                  bottom: -10,
                  child: Column(
                    children: [
                      Text(
                        "Attack",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.cross,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () => widget.onConfirmAttack?.call(card),
                        splashRadius: 24,
                        tooltip: 'Attack',
                      ),
                    ],
                  ),
                ),

              if (card.summoningSickness)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Transform.rotate(
                    angle: -0.8,
                    child: Container(
                      color: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        "SICK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return card.destroyed
        ? UltimateEvolutionEffect(cardImagePath: card.imagePath)
        : cardWidget;

    return card.destroyed
        ? CreatureDestructionEffect(child: cardWidget)
        : cardWidget;
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
