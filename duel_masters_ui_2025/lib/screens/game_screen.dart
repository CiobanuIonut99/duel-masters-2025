import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/card_model.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isSelectingAttackTarget = false;
  CardModel? selectedAttacker;
  bool animateShieldToHand = false;
  bool isTapped = false;

  Offset shieldStartOffset = Offset.zero;
  Offset shieldEndOffset = Offset.zero;

  CardModel? brokenShieldCard;
  double hoverScale = 1.0; // Scale factor for hover effect
  CardModel? hoveredCard;

  List<CardModel> hand = []; // This will be updated with data fetched from the backend
  List<CardModel> shields = []; // This will be updated with data fetched from the backend
  List<CardModel> deck = []; // This will be updated with data fetched from the backend

  int deckSize = 0;  // This will hold the deck size fetched from the backend


  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  Future<void> fetchGameData() async {
    print("Fetching game data from the backend...");

    final response = await http.get(Uri.parse('http://localhost:8080/api/cards/game-state'));

    if (response.statusCode == 200) {
      print("Data fetched successfully!");

      // Log the raw response body for debugging
      print("Response body: ${response.body}");

      // Try decoding as Map<String, dynamic> first (expecting a JSON object structure)
      try {
        final Map<String, dynamic> data = json.decode(response.body);

        // Log the structure after decoding
        print("Decoded response as Map: $data");

        // If the response has 'deck', 'shields', and 'hand' as keys, proceed with mapping them
        if (data.containsKey('deck') && data.containsKey('shields') && data.containsKey('hand')) {
          List<CardModel> fetchedDeck = (data['deck'] as List).map((cardData) {
            return CardModel(
              id: cardData['cardID'],
              name: "Card ${cardData['cardID']}", // Use actual names if available
              manaCost: 0, // Adjust accordingly based on actual response
            );
          }).toList();

          List<CardModel> fetchedShields = (data['shields'] as List).map((cardData) {
            return CardModel(
              id: cardData['cardID'],
              name: "Shield ${cardData['cardID']}", // Use actual names if available
              manaCost: 0, // Adjust accordingly
            );
          }).toList();

          List<CardModel> fetchedHand = (data['hand'] as List).map((cardData) {
            return CardModel(
              id: cardData['cardID'],
              name: "Hand ${cardData['cardID']}", // Use actual names if available
              manaCost: 0, // Adjust accordingly
            );
          }).toList();

          // Log all the fetched data
          print("Fetched deck: ${fetchedDeck.map((card) => card.name).toList()}");
          print("Fetched shields: ${fetchedShields.map((card) => card.name).toList()}");
          print("Fetched hand: ${fetchedHand.map((card) => card.name).toList()}");

          setState(() {
            shields = fetchedShields;
            hand = fetchedHand;
            deck = fetchedDeck;
            deckSize = fetchedDeck.length; // Store the deck size
          });
        } else {
          print("Expected keys 'deck', 'shields', and 'hand' not found in the response.");
        }
      } catch (e) {
        print("Error decoding response as Map: $e");

        // Attempt to handle as a list if it's not a Map
        try {
          final List<dynamic> dataList = json.decode(response.body);
          print("Decoded response as List: $dataList");
        } catch (e) {
          print("Error decoding response as List: $e");
        }
      }
    } else {
      print("Failed to fetch game data. Status code: ${response.statusCode}");
      throw Exception('Failed to load game data');
    }
  }





  final List<CardModel> opponentHandCards = List.generate(
    5,
    (_) => CardModel(id: 0, name: "Unknown", manaCost: 0),
  );


  List<CardModel> opponentShields = List.generate(
    5,
    (index) => CardModel(id: 0, name: "Shield $index", manaCost: 0),
  );

  List<CardModel> battleZoneCards = [];
  List<CardModel> manaZoneCards = [];

  bool hasPlayedManaThisTurn = false;

  List<CardModel> opponentBattleZone = [
    CardModel(id: 3, name: "Aqua Sniper", manaCost: 3),
    CardModel(id: 3, name: "Aqua Sniper", manaCost: 7),
  ];

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

  void resetTurn() {
    setState(() {
      hasPlayedManaThisTurn = false;
    });
  }

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

  void _startAttackSelection(CardModel attacker) {
    setState(() {
      isSelectingAttackTarget = true;
      selectedAttacker = attacker;
    });
  }

  void untapAll() {
    setState(() {
      for (var card in battleZoneCards) card.isTapped = false;
      for (var card in manaZoneCards) card.isTapped = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All cards untapped for new turn")));
  }

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
                      Column(
                        children: [
                          Center(
                            child: _buildCardRow(
                              [],
                              cardWidth: 80,
                              label: "Opponent Battle Zone",
                            ),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: _buildCardRow(
                              battleZoneCards,
                              cardWidth: 80,
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
                  cardWidth: 80,
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




  Widget _buildDeckZone({required int deckSize, required String label, bool rotate180 = false}) {
    return Column(
      children: [
        Transform.rotate(
          angle: rotate180 ? 3.14 : 0,
          child: Image.asset('assets/cards/0.jpg', width: 70),  // Replace with your deck image asset
        ),
        SizedBox(height: 4),
        Text('$label ($deckSize)', style: TextStyle(color: Colors.white)),
      ],
    );
  }





  Widget _buildOpponentField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _buildCardRow(
                opponentHandCards,
                cardWidth: 50,
                label: "Opponent Hand",
                rotate180: true,
              ),
            ),
            _buildManaZone(label: "Opponent Mana", cards: [], rotate180: true),
            _buildDeckZone(
              deckSize: 30,
              label: "Opponent Deck",
              rotate180: true,
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(
              opponentShields,
              cardWidth: 60,
              label: "Opponent Shields",
              rotate180: true,
            ),
          ],
        ),
        SizedBox(height: 12),
        Center(
          child: _buildCardRow(
            opponentBattleZone,
            cardWidth: 80,
            label: "Opponent Battle Zone",
            rotate180: true,
          ),
        ),
      ],
    );
  }





  Widget _buildCardRow(
      List<CardModel> cards, {
        double cardWidth = 60,
        String? label,
        bool scrollable = false,
        bool allowManaAction = false,
        bool rotate180 = false,
      }) {
    final isTargetZone = (label == "Opponent Shields" || label == "Opponent Battle Zone") && isSelectingAttackTarget;

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.map((card) {
        final isGlowTarget = isTargetZone;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                hoveredCard = card;
              });
            },
            onExit: (_) {
              setState(() {
                hoveredCard = null;
              });
            },
            child: GestureDetector(
              onTap: () {
                // Left-click (tap) behavior to show the enlarged card image
                _showFullScreenCardPreview(card);
              },
              onSecondaryTap: allowManaAction
                  ? () => _showHandCardDialog(card)
                  : isGlowTarget
                  ? () {
                if (label == "Opponent Shields") {
                  attackShield(selectedAttacker!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${selectedAttacker!.name} attacked ${card.name}")),
                  );
                }
                setState(() {
                  isSelectingAttackTarget = false;
                  selectedAttacker = null;
                });
              }
                  : (label == "Your Battle Zone" ? () => _startAttackSelection(card) : null),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  boxShadow: isGlowTarget ? [BoxShadow(color: Colors.yellowAccent, blurRadius: 12)] : [],
                ),
                child: Transform.rotate(
                  angle: (card.isTapped ? -1.57 : 0) + (rotate180 ? 3.14 : 0),
                  child: Transform.scale(
                    scale: hoveredCard == card ? 1.2 : 1.0, // Only enlarge the hovered card
                    child: Image.asset(
                      // Check if the card is a shield
                      (label == "Your Shields" || label == "Opponent Shields")
                          ? 'assets/cards/0.jpg'  // Use card back for shields
                          : card.imagePath,  // Use the normal card face otherwise
                      width: cardWidth,
                    ),
                  ),
                ),
              ),
            )

          ),
        );
      }).toList(),
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



  void _showFullScreenCardPreview(CardModel card) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {
              // Close the preview when tapped
              Navigator.pop(context);
            },
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
              width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            ),
          ),
        ),
      ),
    );
  }





  Widget _buildManaZone({
    required String label,
    required List<CardModel> cards,
    bool rotate180 = false,
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
                      child: Transform.rotate(
                        angle: rotate180 ? 3.14 : 0,
                        child: Image.asset(card.imagePath, width: 40),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }





}
