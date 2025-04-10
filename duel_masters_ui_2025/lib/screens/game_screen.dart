import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../animations/fx_game.dart';
import '../models/card_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Current player overall cards
  List<CardModel> playerHand = [];
  List<CardModel> playerDeck = [];
  List<CardModel> playerShields = [];
  List<CardModel> playerManaZone = [];
  List<CardModel> playerGraveyard = [];
  List<CardModel> playerBattleZone = [];

  // Opponent player overall cards
  List<CardModel> opponentHand = [];
  List<CardModel> opponentDeck = [];
  List<CardModel> opponentShields = [];
  List<CardModel> opponentManaZone = [];
  List<CardModel> opponentGraveyard = [];
  List<CardModel> opponentBattleZone = [];

  int deckSize = 0;

  final currentPlayerId = DateTime.now().millisecondsSinceEpoch % 1000000;
  var opponentId;
  var playedMana;

  int? currentTurnPlayerId;

  String? currentGameId;
  String? myPlayerTopic;

  bool hasJoinedMatch = false;

  CardModel? brokenShieldCard;
  CardModel? redGlowShield;
  CardModel? selectedAttacker;
  CardModel? hoveredCard;

  late FxGame fxGame;

  late AnimationController shieldMoveController;
  late Animation<Offset> shieldOffsetAnimation;
  late Animation<double> trembleAnimation;
  late Animation<double> scaleAnimation;

  final GlobalKey _shieldKey = GlobalKey();
  final GlobalKey _opponentHandKey = GlobalKey();

  Offset? opponentHandTarget;
  Offset? shieldOriginGlobal;
  Offset centerScreen = Offset.zero;

  bool isSelectingAttackTarget = false;
  bool animateShieldToHand = false;
  bool isTapped = false;

  double hoverScale = 1.0;

  StompUnsubscribe? sub1;
  StompUnsubscribe? sub2;

  late StompClient stompClient;

  // Initialize entire state
  @override
  void initState() {
    super.initState();
    fetchGameData();
    fxGame = FxGame();
    stompClient = StompClient(
      config: StompConfig(
        url: 'wss://f33b-5-12-128-179.ngrok-free.app/duel-masters-ws',
        onConnect: onStompConnect,
        onWebSocketError: (dynamic error) => print("WebSocket error: $error"),
      ),
    );

    stompClient.activate();

    shieldMoveController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    trembleAnimation = Tween<double>(
      begin: 0,
      end: 48,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(shieldMoveController);

    scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: shieldMoveController,
        curve: Interval(0.0, 0.3), // scale pulse only in the early phase
      ),
    );

    shieldOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-2, -2), // adjust to where opponent's hand is
    ).animate(
      CurvedAnimation(
        parent: shieldMoveController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    shieldMoveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          animateShieldToHand = false;
          opponentShields.remove(redGlowShield);
          opponentHand.add(brokenShieldCard!);
          brokenShieldCard = null;
          redGlowShield = null;
        });
      }
    });
  }

  Future<void> fetchGameData() async {
    print("Fetching game data from the backend...");

    final response = await http.get(
      Uri.parse('https://f33b-5-12-128-179.ngrok-free.app/api/games'),
    );

    if (response.statusCode == 200) {
      print("Data fetched successfully!");
      try {
        final Map<String, dynamic> data = json.decode(response.body);

        // If the response has 'deck', 'shields', and 'hand' as keys, proceed with mapping them
        if (data.containsKey('deck') &&
            data.containsKey('shields') &&
            data.containsKey('hand')) {
          List<CardModel> fetchedDeck =
              (data['deck'] as List).map((cardData) {
                return CardModel(
                  id: cardData['id'],
                  power: cardData['power'],
                  gameCardId: cardData['gameCardId'],
                  name: cardData['name'] ?? "Unknown",
                  type: cardData['type'] ?? "UNKNOWN",
                  civilization: cardData['civilization'] ?? "NONE",
                  race: cardData['race'] ?? "UNKNOWN",
                  manaCost: cardData['manaCost'] ?? 0,
                  manaNumber: cardData['manaNumber'] ?? 0,
                  ability: cardData['ability'] ?? "",
                  specialAbility: cardData['specialAbility'] ?? "",
                );
              }).toList();

          List<CardModel> fetchedShields =
              (data['shields'] as List).map((cardData) {
                return CardModel(
                  id: cardData['id'],
                  power: cardData['power'],
                  gameCardId: cardData['gameCardId'],
                  name: cardData['name'] ?? "Unknown",
                  type: cardData['type'] ?? "UNKNOWN",
                  civilization: cardData['civilization'] ?? "NONE",
                  race: cardData['race'] ?? "UNKNOWN",
                  manaCost: cardData['manaCost'] ?? 0,
                  manaNumber: cardData['manaNumber'] ?? 0,
                  ability: cardData['ability'] ?? "",
                  specialAbility: cardData['specialAbility'] ?? "",
                );
              }).toList();

          List<CardModel> fetchedHand =
              (data['hand'] as List).map((cardData) {
                return CardModel(
                  id: cardData['id'],
                  power: cardData['power'],
                  gameCardId: cardData['gameCardId'],
                  name: cardData['name'] ?? "Unknown",
                  type: cardData['type'] ?? "UNKNOWN",
                  civilization: cardData['civilization'] ?? "NONE",
                  race: cardData['race'] ?? "UNKNOWN",
                  manaCost: cardData['manaCost'] ?? 0,
                  manaNumber: cardData['manaNumber'] ?? 0,
                  ability: cardData['ability'] ?? "",
                  specialAbility: cardData['specialAbility'] ?? "",
                );
              }).toList();

          setState(() {
            playerHand = fetchedHand;
            playerDeck = fetchedDeck;
            playerShields = fetchedShields;
            deckSize = fetchedDeck.length;
          });
        } else {
          print(
            "Expected keys 'deck', 'shields', and 'hand' not found in the response.",
          );
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

  // Connect with backend WS throgh STOMP
  void onStompConnect(StompFrame frame) {
    print("✅ Connected to WebSocket");

    stompClient.subscribe(
      destination: '/topic/matchmaking',
      callback: (frame) {
        final List<dynamic> gameStates = jsonDecode(frame.body!);

        for (var state in gameStates) {
          if (state['playerId'] == currentPlayerId) {
            final gameId = state['gameId'];
            final playerTopic = state['playerTopic'];

            print(
              "🎮 Matched! Subscribing to: /topic/game/$gameId/$playerTopic",
            );

            stompClient.subscribe(
              destination: '/topic/game/$gameId/$playerTopic',
              callback: (frame) {
                print("📡 Subscribed to: /topic/game/$gameId/$playerTopic");
                final responseBody = jsonDecode(frame.body!);
                currentGameId = responseBody['gameId'];
                myPlayerTopic = responseBody['playerTopic'];
                currentTurnPlayerId = responseBody['currentTurnPlayerId'];
                opponentId = responseBody['opponentId'];
                playedMana = responseBody['playedMana'];
                print("gameId : $currentGameId");
                print("currentTurnPlayerId : $currentTurnPlayerId");

                // Parse your player zones
                final updatedPlayerHand =
                    (responseBody['playerHand'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();
                final updatedPlayerShields =
                    (responseBody['playerShields'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();
                final updatedPlayerDeck =
                    (responseBody['playerDeck'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();
                final updatedPlayerManaZone =
                    (responseBody['playerManaZone'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();
                final updatedPlayerBattleZone =
                    (responseBody['playerBattleZone'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();
                final updatedPlayerGraveyard =
                    (responseBody['playerGraveyard'] as List)
                        .map((c) => CardModel.fromJson(c))
                        .toList();

                final updatedOpponentHand =
                    (responseBody['opponentHand'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];
                final updatedOpponentShields =
                    (responseBody['opponentShields'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];
                final updatetOpponentDeck =
                    (responseBody['opponentDeck'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];
                final updatedOpponentManaZone =
                    (responseBody['opponentManaZone'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];
                final updatedOpponentBattleZone =
                    (responseBody['opponentBattleZone'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];
                final updatedOpponentGraveyard =
                    (responseBody['opponentGraveyard'] as List?)
                        ?.map((c) => CardModel.fromJson(c))
                        .toList() ??
                    [];

                setState(() {
                  // Your zones
                  deckSize = updatedPlayerDeck.length;
                  playerHand = updatedPlayerHand;
                  playerShields = updatedPlayerShields;
                  playerDeck = updatedPlayerDeck;
                  playerManaZone = updatedPlayerManaZone;
                  playerGraveyard = updatedPlayerGraveyard;
                  playerBattleZone = updatedPlayerBattleZone;

                  // Opponent zones
                  opponentHand = updatedOpponentHand;
                  opponentShields = updatedOpponentShields;
                  opponentDeck = updatetOpponentDeck;
                  opponentManaZone = updatedOpponentManaZone;
                  opponentGraveyard = updatedOpponentGraveyard;
                  opponentBattleZone = updatedOpponentBattleZone;
                });
              },
            );

            setState(() {
              hasJoinedMatch = true;
            });

            break;
          }
        }
      },
    );
  }

  void _searchForMatch() {
    if (stompClient.connected) {
      final randomId = currentPlayerId;
      final randomUsername = "player_$randomId";
      stompClient.send(
        destination: '/duel-masters/game/start',
        body: jsonEncode({
          "id": randomId,
          "username": randomUsername,
          "playerHand": playerHand.map((card) => card.toJson()).toList(),
          "playerShields": playerShields.map((card) => card.toJson()).toList(),
          "playerDeck": playerDeck.map((card) => card.toJson()).toList(),
        }),
        headers: {'content-type': 'application/json'},
      );

      print("🔄 Searching for match as $randomUsername ($randomId)");
      log("🔄 Searching for match as $randomUsername ($randomId)");

      setState(() {
        hasJoinedMatch = true;
      });
    }
  }

  @override
  void dispose() {
    shieldMoveController.dispose();
    stompClient.deactivate();
    super.dispose();
  }

  bool hasPlayedManaThisTurn = false;


  Widget _buildZoneLabel(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.
        withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void sendToMana(CardModel card) {
    if (hasPlayedManaThisTurn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only send one card to mana per turn.")),
      );
      return;
    }

    final payload = {
      "gameId": currentGameId,
      "playerId": currentPlayerId,
      "playerTopic": myPlayerTopic,
      "action": "SEND_CARD_TO_MANA",
      "triggeredGameCardId": card.gameCardId,
    };

    if (stompClient.connected) {
      stompClient.send(
        destination: '/duel-masters/game/action',
        body: jsonEncode(payload),
      );

      setState(() {
        // hasPlayedManaThisTurn = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${card.name} sent to mana zone!")),
      );
    }
  }


  void sendToGraveyard(CardModel card) {
  }

  void resetTurn() {
    setState(() {
      hasPlayedManaThisTurn = false;
    });
  }

  void summonCard(CardModel card) {
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
                  onPressed: playedMana
                    ? null
                : () {
                    Navigator.pop(context);
                    sendToMana(card);
                  },
                  child: Text("Send to Mana Zone"),
                ),
                if (playedMana)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "You already sent a card to mana this turn!",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    summonCard(card);
                  },
                  child: Text("Summon to Battle Zone"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    sendToGraveyard(card);
                  },
                  child: Text("Send to Graveyard"),
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

  void attackShield(CardModel attacker, CardModel targetShield) {
    if (attacker.isTapped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${attacker.name} is tapped and cannot attack!"),
        ),
      );
      return;
    }

    // Get the real reference from the list
    final actualShield = opponentShields.firstWhere(
      (c) => identical(c, targetShield),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _shieldKey.currentContext?.findRenderObject() as RenderBox?;
      final position =
          renderBox?.localToGlobal(Offset.zero) ?? Offset(150, 200);

      final opponentHandBox =
          _opponentHandKey.currentContext?.findRenderObject() as RenderBox?;
      final handPos =
          opponentHandBox?.localToGlobal(Offset.zero) ?? Offset(50, 50);

      setState(() {
        shieldOriginGlobal = position;
        opponentHandTarget = handPos;
        centerScreen = Offset(
          MediaQuery.of(context).size.width / 2 - 50,
          MediaQuery.of(context).size.height / 2 - 75,
        );

        brokenShieldCard = actualShield;
        redGlowShield = actualShield;
        animateShieldToHand = true;
        attacker.isTapped = true;
      });

      shieldMoveController.reset();
      shieldMoveController.forward();
    });
  }

  void _startAttackSelection(CardModel attacker) {
    setState(() {
      isSelectingAttackTarget = true;
      selectedAttacker = attacker;
    });
  }

  void endTurn() {
    final payload = {
      "gameId": currentGameId,
      "playerId": currentPlayerId,
      "opponentId": opponentId,
      "currentTurnPlayerId":currentTurnPlayerId,
      "action": "END_TURN",
    };

    if (stompClient.connected) {
      stompClient.send(
        destination: '/duel-masters/game/action',
        body: jsonEncode(payload),
      );

      setState(() {
        // hasPlayedManaThisTurn = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Drew one card from deck")),
      );
    }

    setState(() {
    });

    // Show a message that the turn has ended
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All cards untapped for new turn")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Duel Masters - Match Start"),
            if (currentTurnPlayerId != null)
              Text(
                currentTurnPlayerId == currentPlayerId
                    ? "Your Turn"
                    : "Opponent's Turn",
                style: TextStyle(
                  color: currentTurnPlayerId == currentPlayerId
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed:
                      hasJoinedMatch
                          ? null
                          : () {
                            _searchForMatch();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🔍 Looking for opponent..."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                  icon: Icon(Icons.person_search),
                  label: Text("Search Match"),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: endTurn,
                  icon: Icon(Icons.refresh),
                  label: Text("End Turn"),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // 🌲 Forest Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/forest_board.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔥 Flame animation FX layer (shield breaking, etc.)
          Positioned.fill(child: GameWidget(game: fxGame)),

          // 🎴 Main game board UI
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
                              cardWidth: 100,
                              label: "Opponent Battle Zone",
                            ),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: _buildCardRow(
                              playerBattleZone,
                              cardWidth: 100,
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

          // 🛡️ Shield flying to hand animation
          if (animateShieldToHand && brokenShieldCard != null)
            _buildShieldBreakAnimation(),
        ],
      ),
    );
  }

  // 🛡️ Shield card flies to opponent hand after trembling
  Widget _buildShieldBreakAnimation() {
    if (!animateShieldToHand ||
        brokenShieldCard == null ||
        shieldOriginGlobal == null ||
        opponentHandTarget == null) {
      return SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: shieldMoveController,
      builder: (context, child) {
        final progress = shieldMoveController.value;

        Offset currentOffset;
        double scale = 1.0;
        double rotation = 0;

        if (progress < 0.3) {
          // Move from shield to center
          currentOffset =
              Offset.lerp(shieldOriginGlobal, centerScreen, progress / 0.3)!;
        } else if (progress < 0.6) {
          // Stay in center and animate
          currentOffset = centerScreen;

          final innerProgress = (progress - 0.3) / 0.3;
          scale = 1.0 - (0.2 * (0.5 - (innerProgress - 0.5).abs()) * 2);
          rotation = 6.28 * innerProgress; // full 360°
        } else {
          // Fly to opponent's hand
          currentOffset =
              Offset.lerp(
                centerScreen,
                opponentHandTarget!,
                (progress - 0.6) / 0.4,
              )!;
          rotation = 6.28; // final rotation
        }

        return Positioned(
          left: currentOffset.dx,
          top: currentOffset.dy,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: Offset(-10, -10),
                    ),
                    BoxShadow(
                      color: Colors.blueAccent.withValues(),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: Offset(10, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/cards/0.jpg',
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(playerShields, cardWidth: 80, label: "Your Shields"),
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
                  playerHand,
                  cardWidth: 100,
                  label: "Your Hand",
                  scrollable: true,
                  allowManaAction: true,
                ),
              ),
            ),
            _buildGraveyardZone(label: "Graveyard", cards: playerGraveyard),
            // Player's graveyard
            _buildManaZone(label: "Your Mana", cards: playerManaZone),
            // Player's mana
            _buildDeckZone(deckSize: deckSize, label: "Your Deck"),
          ],
        ),
      ],
    );
  }

  Widget _buildDeckZone({
    required int deckSize,
    required String label,
    bool rotate180 = false,
  }) {
    return Column(
      children: [
        Transform.rotate(
          angle: rotate180 ? 3.14 : 0,
          child: Image.asset(
            'assets/cards/0.jpg',
            width: 70,
          ), // Replace with your deck image asset
        ),
        SizedBox(height: 4),
        _buildZoneLabel('$label ($deckSize)'),
      ],
    );
  }

  Widget _buildOpponentField() {
    return Column(
      children: [
        // Hand | Graveyard | Mana | Deck
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Opponent Hand (scrollable, left-aligned)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCardRow(
                  opponentHand,
                  cardWidth: 100,
                  label: "Opponent Hand",
                  scrollable: true,
                  rotate180: true,
                ),
              ),
            ),

            // Graveyard
            _buildGraveyardZone(label: "Opponent Graveyard", cards: []),

            // Mana
            _buildManaZone(label: "Opponent Mana", cards: opponentManaZone, rotate180: true),

            // Deck
            _buildDeckZone(
              deckSize: 30,
              label: "Opponent Deck",
              rotate180: true,
            ),
          ],
        ),
        // Opponent Shields centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardRow(
              opponentShields,
              cardWidth: 80,
              label: "Opponent Shields",
              // rotate180: true,
            ),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }

  void randomizeTurnPlayer() {
    if (stompClient.connected) {
      final payload = {
        "gameId": currentGameId,
        "playerId": currentPlayerId,
        "playerTopic": myPlayerTopic,
        "action": "RANDOMIZE_TURN_PLAYER",
      };

      stompClient.send(
        destination: '/duel-masters/game/action',
        body: jsonEncode(payload),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔀 Randomizing Turn Player...")),
      );
    }
  }


  Widget _buildCardRow(
    List<CardModel> cards, {
    double cardWidth = 60,
    String? label,
    bool scrollable = false,
    bool allowManaAction = false,
    bool rotate180 = false,
  }) {
    final isTargetZone =
        (label == "Opponent Shields" || label == "Opponent Battle Zone") &&
        isSelectingAttackTarget;

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          cards.map((card) {
            final isGlowTarget = isTargetZone;
            bool isRedGlow = brokenShieldCard != null;
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
                    if (!card.name.startsWith("Shield") &&
                        !opponentHand.contains(card)) {
                      _showFullScreenCardPreview(card);
                    }
                    if (card.isTapped) return;
                    setState(() {
                      hoveredCard = card;
                    });
                  },
                  onSecondaryTap:
                      allowManaAction
                          ? () => _showHandCardDialog(card)
                          : isGlowTarget
                          ? () {
                            if (label == "Opponent Shields") {
                              attackShield(selectedAttacker!, card);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${selectedAttacker!.name} attacked ${card.name}",
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              isSelectingAttackTarget = false;
                              selectedAttacker = null;
                            });
                          }
                          : (label == "Your Battle Zone" && !card.isTapped
                              ? () => _startAttackSelection(card)
                              : null),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 1),
                    decoration: BoxDecoration(
                      boxShadow: [
                        if (isRedGlow)
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        else if (isTargetZone)
                          BoxShadow(
                            color: Colors.greenAccent,
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        else if ((label?.contains("Shields") ?? false))
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                      ],
                    ),

                    child: Container(
                      key:
                          label == "Opponent Shields" &&
                                  card == opponentShields.first
                              ? _shieldKey
                              : null,
                      child: Transform.rotate(
                        angle:
                            (card.isTapped ? -1.57 : 0) +
                            (rotate180 ? 3.14 : 0),
                        child: Transform.scale(
                          scale: hoveredCard == card ? 1.2 : 1.0,
                          child: Stack(
                            children: [
                              Image.asset(
                                label == "Your Shields" ||
                                        label == "Opponent Shields"
                                    ? 'assets/cards/0.jpg'
                                    : (label == "Opponent Hand"
                                        ? 'assets/cards/0.jpg'
                                        : card.imagePath),
                                width: cardWidth,
                              ),

                              if (card.isTapped && hoveredCard == card)
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.7),
                                    child: Text(
                                      "Tapped / Cannot Attack",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) _buildZoneLabel(label),

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
      builder:
          (_) => Dialog(
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
                  height:
                      MediaQuery.of(context).size.height *
                      0.8, // 80% of screen height
                  width:
                      MediaQuery.of(context).size.width *
                      0.8, // 80% of screen width
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildGraveyardZone({
    required String label,
    required List<CardModel> cards,
    bool rotate180 = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCardZoneDialog(label, cards, rotate180),
          child: SizedBox(
            height: 70,
            width: 60,
            child: Stack(
              alignment: Alignment.topCenter,
              children:
                  cards.asMap().entries.map((entry) {
                    final card = entry.value;
                    return Positioned(
                      top: 0,
                      child: Transform.rotate(
                        angle: rotate180 ? 3.14 : 0,
                        child: Image.asset(card.imagePath, width: 60),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        SizedBox(height: 4),
        _buildZoneLabel(label),
      ],
    );
  }

  Widget _buildManaZone({
    required String label,
    required List<CardModel> cards,
    bool rotate180 = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCardZoneDialog(label, cards, rotate180),
          child: SizedBox(
            height: 70,
            width: 60,
            child: Stack(
              alignment: Alignment.topCenter,
              children:
                  cards.asMap().entries.map((entry) {
                    final card = entry.value;
                    return Positioned(
                      top: 0,
                      child: Transform.rotate(
                        angle: rotate180 ? 3.14 : 0,
                        child: Image.asset(card.imagePath, width: 60),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        SizedBox(height: 4),
        _buildZoneLabel(label),
      ],
    );
  }

  void _showCardZoneDialog(
    String label,
    List<CardModel> cards, [
    bool rotate180 = false,
  ]) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black87,
            insetPadding: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          cards.map((card) {
                            return GestureDetector(
                              onTap: () => _showFullScreenCardPreview(card),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Transform.rotate(
                                  angle: rotate180 ? 3.14 : 0,
                                  child: Image.asset(
                                    card.imagePath,
                                    width: 130,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
