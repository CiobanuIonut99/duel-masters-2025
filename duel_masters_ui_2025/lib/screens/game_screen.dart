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
  "shields": List.generate(5, (index) => {
    "id": 0, // use 0 for back image
    "name": "Shield $index",
  }),
  "deckSize": 30
};


// 🖼️ Main Game UI Widget
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<CardModel> hand = (mockGameStartResponse["hand"] as List<dynamic>)
      .map((data) => CardModel(
    id: data["id"],
    name: data["name"],
    manaCost: data["manaCost"] ?? 1,
  ))
      .toList();

  final List<CardModel> shields = (mockGameStartResponse["shields"] as List<dynamic>)
      .map((data) => CardModel(
    id: data["id"],
    name: data["name"],
    manaCost: 0,
  ))
      .toList();


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
      builder: (context) => AlertDialog(
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

  // 🧱 Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(title: Text("Duel Masters - Match Start")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOpponentField(), // 🔼 Opponent field

            // ⚔️ Battle Zones
            Column(
              children: [
                Center(child: _buildCardRow([], cardWidth: 90, label: "Opponent Battle Zone")),
                SizedBox(height: 12),
                Center(child: _buildCardRow(battleZoneCards, cardWidth: 90, label: "Your Battle Zone")),
              ],
            ),

            _buildPlayerField(), // 🔽 Player field
          ],
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDeckZone(deckSize: 30, label: "Opponent Deck"),
            _buildCardRow(
              List.generate(
                5,
                    (_) => CardModel(id: 0, name: "Unknown", manaCost: 0)
                ,
              ),
              cardWidth: 60,
              label: "Opponent Shields",
            ),
            _buildManaZone(label: "Opponent Mana", cards: []),
          ],
        ),
        SizedBox(height: 12),
        _buildCardRow(
          List.generate(
            5,
                (_) => CardModel(id: 0, name: "Unknown", manaCost: 0)
            ,
          ),
          cardWidth: 50,
          label: "Opponent Hand",
        ),
      ],
    );
  }

  // 🧱 Generic row of cards
  Widget _buildCardRow(List<CardModel> cards, {
    double cardWidth = 60,
    String? label,
    bool scrollable = false,
    bool allowManaAction = false,
  }) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.map((card) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: allowManaAction ? () => _showHandCardDialog(card) : null,
          child: Image.asset(card.imagePath, width: cardWidth),
        ),
      )).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) Text(label, style: TextStyle(color: Colors.white)),
        SizedBox(height: 4),
        scrollable
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
            : row,
      ],
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
  Widget _buildManaZone({required String label, required List<CardModel> cards}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        SizedBox(height: 4),
        Row(
          children: cards.map((card) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(card.imagePath, width: 40),
          )).toList(),
        ),
      ],
    );
  }
}
