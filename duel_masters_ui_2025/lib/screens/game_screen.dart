// 📦 Imports
import 'package:flutter/material.dart';

import '../models/card_model.dart';

// 🔧 Mock data simulating backend response
final mockGameStartResponse = {
  "hand": [
    {"id": 79, "name": "Bolshack Dragon", "manaCost": 6},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
    {"id": 79, "name": "Bolshack Dragon", "manaCost": 6},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
    {"id": 3, "name": "Aqua Sniper", "manaCost": 1},
  ],
  "shields": List.generate(
    5,
    (index) => {
      "id": 0, // use 0 for back image
      "name": "Shield $index",
    },
  ),
  "deckSize": 30,
};

// 🖼️ Main Game UI Widget
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool animateShieldToHand = false;
  bool isTapped = false;
  Offset shieldStartOffset = Offset.zero;
  Offset shieldEndOffset = Offset.zero;
  CardModel? brokenShieldCard;

  final List<CardModel> opponentHandCards =List.generate(
    5,
        (_) => CardModel(id: 0, name: "Unknown", manaCost: 0),
  );

  final List<CardModel> hand =
      (mockGameStartResponse["hand"] as List<dynamic>)
          .map(
            (data) => CardModel(
              id: data["id"],
              name: data["name"],
              manaCost: data["manaCost"] ?? 1,
            ),
          )
          .toList();

  final List<CardModel> shields =
      (mockGameStartResponse["shields"] as List<dynamic>)
          .map(
            (data) =>
                CardModel(id: data["id"], name: data["name"], manaCost: 0),
          )
          .toList();

  List<CardModel> opponentShields = List.generate(
    5,
    (index) => CardModel(id: 0, name: "Shield $index", manaCost: 0),
  );

  // 🔢 Player Deck Size
  final int deckSize = mockGameStartResponse["deckSize"] as int;

  // ♻️ Game State
  List<CardModel> battleZoneCards = [];
  List<CardModel> manaZoneCards = [];
  bool hasPlayedManaThisTurn = false;

  // 🔁 Send card to Mana Zone
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

  // 🔁 Reset turn logic
  void resetTurn() {
    setState(() {
      hasPlayedManaThisTurn = false;
    });
  }

  // 🧙 Summon creature to battle zone
  void summonCard(CardModel card) {
    if (manaZoneCards.length < card.manaCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough mana to summon \${card.name}")),
      );
      return;
    }
    setState(() {
      hand.remove(card);
      battleZoneCards.add(card);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("\${card.name} summoned to battle zone!")),
    );
  }

  // 🧠 Show hand options (summon, mana)
  void _showHandCardDialog(CardModel card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  // 🧠 Show battle card options in battleground (attack, tap etc)
  // void _showBattleCardOptions(CardModel card) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text("Attack with ${card.name}?"),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   // This is where you'd call backend: attack opponent
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("${card.name} attacked opponent!"),
  //                     ),
  //                   );
  //                 },
  //                 child: Text("Attack Opponent"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("${card.name} attacked a shield!"),
  //                     ),
  //                   );
  //                 },
  //                 child: Text("Attack Shield"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("${card.name} attacked enemy creature!"),
  //                     ),
  //                   );
  //                 },
  //                 child: Text("Attack Creature"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text("Cancel"),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }
  void untapAll() {
    setState(() {
      // Untap all creatures in battle zone
      for (var card in battleZoneCards) {
        card.isTapped = false;
      }

      // Untap all mana cards
      for (var card in manaZoneCards) {
        card.isTapped = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All cards untapped for new turn")),
    );
  }

  void attackShield(CardModel card) {
    if (opponentShields.isEmpty) return;

    final removedShield = opponentShields.first;

    setState(() {
      brokenShieldCard = removedShield;
      animateShieldToHand = true;
      shieldStartOffset = Offset(150, 200);
      shieldEndOffset = Offset(20, 50);
      card.isTapped = true;
    });

    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        animateShieldToHand = false;
        brokenShieldCard = null;
        opponentShields.removeAt(0); // remove first shield
        opponentHandCards.add(removedShield); // add it to opponent's hand
      });
    });
  }

  // 🧱 Build UI
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
          )
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOpponentField(),
                Column(
                  children: [
                    Center(
                      child: _buildCardRow(
                        [],
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
                _buildPlayerField(),
              ],
            ),
          ),

          // Animated shield movement
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

  // 🧙 Player Field (shields, mana, hand)
  Widget _buildPlayerField() {
    return Column(
      children: [
        // 🔽 Shields Row Centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(shields, cardWidth: 60, label: "Your Shields"),
          ],
        ),
        SizedBox(height: 12),

        // 🔽 Mana & Deck Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🃏 Left aligned Hand
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

            // 🔋 Your Mana Zone
            _buildManaZone(label: "Your Mana", cards: manaZoneCards),

            // 📦 Deck
            _buildDeckZone(deckSize: deckSize, label: "Your Deck"),
          ],
        ),
      ],
    );
  }

  // 🧙 Opponent Field (shields, mana, hand)
  Widget _buildOpponentField() {
    return Column(
      children: [
        // Opponent Hand Row (Left), Mana (Right), Deck (Far Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Opponent Hand
            _buildCardRow(
              opponentHandCards,
              cardWidth: 50,
              label: "Opponent Hand",
            ),

            // Opponent Mana
            _buildManaZone(label: "Opponent Mana", cards: []),
            // Opponent Deck
            _buildDeckZone(deckSize: 30, label: "Opponent Deck"),
          ],
        ),
        SizedBox(height: 12),
        // Opponent Shields Centered
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
      ],
    );
  }
  void _showCardPreview(CardModel card) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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

  // 🧱 Generic row of cards
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
                      angle: card.isTapped ? -1.57 : 0, // -90 degrees in radians
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
                    attackShield(card);
                  },
                  child: Text("Attack Shield"),
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

  // 📦 Deck UI Component
  Widget _buildDeckZone({required int deckSize, required String label}) {
    return Column(
      children: [
        Image.asset('assets/cards/0.jpg', width: 70),
        SizedBox(height: 4),
        Text('$label ($deckSize)', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  // 💠 Mana Zone UI
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
