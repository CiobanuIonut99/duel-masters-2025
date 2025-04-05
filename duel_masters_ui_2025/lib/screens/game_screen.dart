// 📦 Imports
import 'package:flutter/material.dart';

import '../models/card_model.dart';

// 🔧 Mock data simulating a backend response for starting the game
final mockGameStartResponse = {
  "hand": [
    {"id": 79, "name": "Bolshack Dragon", "manaCost": 6},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
    {"id": 79, "name": "Bolshack Dragon", "manaCost": 6},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
  ],
  "shields": List.generate(5, (index) => {"id": 0, "name": "Shield $index"}),
  "deckSize": 30,
};

/// Main Game UI screen
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Whether we are currently animating a broken shield
  bool animateShieldToHand = false;

  // Controls tapping of creatures after they attack
  bool isTapped = false;

  // Coordinates for animating the shield move
  Offset shieldStartOffset = Offset.zero;
  Offset shieldEndOffset = Offset.zero;

  // The shield being broken
  CardModel? brokenShieldCard;

  // Initial mock hand for opponent (5 hidden cards)
  final List<CardModel> opponentHandCards = List.generate(
    5,
    (_) => CardModel(id: 0, name: "Unknown", manaCost: 0),
  );

  // Initial hand from mock response
  final List<CardModel> hand =
      (mockGameStartResponse["hand"] as List)
          .map(
            (data) => CardModel(
              id: data["id"],
              name: data["name"],
              manaCost: data["manaCost"] ?? 1,
            ),
          )
          .toList();

  // Initial shield setup
  final List<CardModel> shields =
      (mockGameStartResponse["shields"] as List)
          .map(
            (data) =>
                CardModel(id: data["id"], name: data["name"], manaCost: 0),
          )
          .toList();

  // Opponent shield row (all hidden cards)
  List<CardModel> opponentShields = List.generate(
    5,
    (index) => CardModel(id: 0, name: "Shield $index", manaCost: 0),
  );

  // Number of cards in deck
  final int deckSize = mockGameStartResponse["deckSize"] as int;

  // Zones
  List<CardModel> battleZoneCards = [];
  List<CardModel> manaZoneCards = [];

  // Ensures only one card is played to mana per turn
  bool hasPlayedManaThisTurn = false;

  // Mocked battlezone for opponent
  List<CardModel> opponentBattleZone = [
    CardModel(id: 3, name: "Aqua Sniper", manaCost: 3),
    CardModel(id: 3, name: "Aqua Sniper", manaCost: 7),
  ];

  /// Sends card to mana zone from hand
  void sendToMana(CardModel card) {
    if (hasPlayedManaThisTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only play 1 mana per turn.")),
      );
      return;
    }
    setState(() {
      manaZoneCards.add(card);
      hand.remove(card);
      hasPlayedManaThisTurn = true;
    });
  }

  /// Resets mana turn limit
  void resetTurn() {
    setState(() {
      hasPlayedManaThisTurn = false;
    });
  }

  /// Summons a creature from hand to battle zone
  void summonCard(CardModel card) {
    if (manaZoneCards.length < card.manaCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough mana to summon ${card.name}")),
      );
      return;
    }
    setState(() {
      hand.remove(card);
      battleZoneCards.add(card);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${card.name} summoned to battle zone!")),
    );
  }

  /// Lets user pick action for a hand card
  void _showHandCardDialog(CardModel card) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(card.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    sendToMana(card);
                  },
                  child: Text("Send to Mana Zone"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    summonCard(card);
                  },
                  child: Text("Summon to Battle Zone"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
    );
  }

  /// Attacks a shield and triggers its animation to opponent's hand
  void attackShield(CardModel card) {
    if (opponentShields.isEmpty) return;
    final removedShield = opponentShields.first;
    setState(() {
      brokenShieldCard = removedShield;
      animateShieldToHand = true;
      shieldStartOffset = Offset(150, 200); // Mock position
      shieldEndOffset = Offset(20, 50);
      card.isTapped = true; // Visually tap attacker
    });

    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        animateShieldToHand = false;
        brokenShieldCard = null;
        opponentShields.removeAt(0);
        opponentHandCards.add(removedShield);
      });
    });
  }

  /// Displays dialog to choose what to attack
  void _showAttackOptionsDialog(CardModel card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Attack with ${card.name}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${card.name} attacked opponent directly!",
                        ),
                      ),
                    );
                  },
                  child: Text("Attack Opponent"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    attackShield(card);
                  },
                  child: Text("Attack Shield"),
                ),
                ...opponentBattleZone.map(
                  (enemy) => ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${card.name} attacked ${enemy.name}!"),
                        ),
                      );
                    },
                    child: Text("Attack ${enemy.name}"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
    );
  }

  /// Untaps all cards for a new turn
  void untapAll() {
    setState(() {
      for (var card in battleZoneCards) card.isTapped = false;
      for (var card in manaZoneCards) card.isTapped = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All cards untapped for new turn")));
  }

  /// Enlarges the card image in a modal
  void _showCardPreview(CardModel card) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 250,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(card.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
    );
  }

  /// Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: Text("Duel Masters - Match Start"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Untap All",
            onPressed: untapAll,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🧱 Scrollable area for all content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOpponentField(),
                      SizedBox(height: 16),

                      // 🛡 Battle Zones
                      Column(
                        children: [
                          Center(
                            child: _buildCardRow(
                              [], // Replace with actual opponent creatures later
                              cardWidth: 90,
                              label: "Opponent Battle Zone",
                            ),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: _buildCardRow(
                              battleZoneCards,
                              cardWidth: 90,
                              label: "Your Battle Zone",
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),
                      _buildPlayerField(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🌀 Shield Animation Layer
          if (animateShieldToHand && brokenShieldCard != null)
            AnimatedPositioned(
              duration: Duration(milliseconds: 800),
              left: shieldEndOffset.dx,
              top: shieldEndOffset.dy,
              child: Image.asset(brokenShieldCard!.imagePath, width: 60),
            ),
        ],
      ),
    );
  }


  /// Builds all elements of the player's side
  Widget _buildPlayerField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(shields, cardWidth: 60, label: "Your Shields"),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCardRow(
                  hand,
                  cardWidth: 90,
                  label: "Your Hand",
                  scrollable: true,
                  allowManaAction: true,
                ),
              ),
            ),
            _buildManaZone(label: "Your Mana", cards: manaZoneCards),
            _buildDeckZone(deckSize: deckSize, label: "Your Deck"),
          ],
        ),
      ],
    );
  }

  Widget _buildOpponentField() {
    return Column(
      children: [
        // Opponent Shields (should come before the battle zone)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(
              opponentShields,
              cardWidth: 60,
              label: "Opponent Shields",
            ),
          ],
        ),
        SizedBox(height: 12),

        // Opponent Battle Zone
        Center(
          child: _buildCardRow(opponentBattleZone, cardWidth: 90, label: "Opponent Battle Zone"),
        ),

        SizedBox(height: 12),

        // Opponent Hand, Mana, and Deck (as a row)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardRow(opponentHandCards, cardWidth: 50, label: "Opponent Hand"),
            _buildManaZone(label: "Opponent Mana", cards: []),
            _buildDeckZone(deckSize: 30, label: "Opponent Deck"),
          ],
        ),
      ],
    );
  }


  /// Generic row for cards (used by all zones)
  Widget _buildCardRow(
    List<CardModel> cards, {
    double cardWidth = 60,
    String? label,
    bool scrollable = false,
    bool allowManaAction = false,
  }) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          cards
              .map(
                (card) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      if (allowManaAction) {
                        _showHandCardDialog(card);
                      } else if (label == "Your Battle Zone") {
                        _showAttackOptionsDialog(card);
                      }
                    },
                    child: Transform.rotate(
                      angle: card.isTapped ? -1.57 : 0,
                      child: Image.asset(card.imagePath, width: cardWidth),
                    ),
                  ),
                ),
              )
              .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) Text(label, style: TextStyle(color: Colors.white)),
        SizedBox(height: 4),
        scrollable
            ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: row,
            )
            : row,
      ],
    );
  }

  /// UI for deck zone
  Widget _buildDeckZone({required int deckSize, required String label}) {
    return Column(
      children: [
        Image.asset('assets/cards/0.jpg', width: 70),
        SizedBox(height: 4),
        Text('$label ($deckSize)', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  /// UI for mana zone
  Widget _buildManaZone({
    required String label,
    required List<CardModel> cards,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        SizedBox(height: 4),
        Row(
          children:
              cards
                  .map(
                    (card) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Image.asset(card.imagePath, width: 40),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
