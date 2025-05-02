import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../dialogs/blocker_selection_dialog.dart';
import '../dialogs/creature_selection_dialog.dart';
import '../dialogs/mana_selection_dialog.dart';
import '../dialogs/select_cards_from_deck_dialog.dart';
import '../dialogs/shield_trigger_dialog.dart';
import '../dialogs/styled_dialog_container.dart';
import '../dialogs/two_rows_selection_creature.dart';
import '../models/card_model.dart';
import '../models/shiel_trigger_flags_dto.dart';
import '../network/game_state_parse.dart';
import '../network/game_websocket_handler.dart';
import '../widgets/opponent_field.dart';
import '../widgets/player_field.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool opponentHasBlocker = false;
  bool shieldTrigger = false;
  CardModel? selectedBlocker;
  CardModel? selectedCreature;

  ShieldTriggersFlagsDto? shieldFlags;

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

  List<CardModel> spiralGatePlayerBattleZone = [];
  List<CardModel> spiralGateOpponentBattleZone = [];


  Set<String> glowingManaCardIds = {};
  Set<String> glowAttackableShields = {};
  Set<String> glowAttackableCreatures = {};

  int deckSize = 0;
  int opponentDeckSize = 0;

  final currentPlayerId = DateTime.now().millisecondsSinceEpoch % 1000000;
  int? previousTurnPlayerId;

  int opponentId = 0;
  bool playedMana = false;

  int? currentTurnPlayerId;

  String? currentGameId;
  String? attackerId;
  String? myPlayerTopic;

  bool hasJoinedMatch = false;

  CardModel? brokenShieldCard;
  CardModel? redGlowShield;
  CardModel? selectedAttacker;
  CardModel? selectedTarget;
  CardModel? hoveredCard;
  CardModel? shieldTriggerCard;

  bool isConnected = false;

  late AnimationController shieldMoveController;
  late Animation<Offset> shieldOffsetAnimation;
  late Animation<double> trembleAnimation;
  late Animation<double> scaleAnimation;

  Offset? opponentHandTarget;
  Offset? shieldOriginGlobal;
  Offset centerScreen = Offset.zero;

  bool isSelectingAttackTarget = false;
  bool animateShieldToHand = false;
  bool tapped = false;

  bool solarRayMustSelectCreature = false;
  bool spiralGateMustSelectCreature = false;
  bool brainSerumMustDrawCards = false;
  bool crystalMemoryMustDrawCard = false;

  List<CardModel> opponentSelectableCreatures = [];
  CardModel? selectedOpponentCreature;

  double hoverScale = 1.0;

  StompUnsubscribe? sub1;
  StompUnsubscribe? sub2;

  late StompClient stompClient;
  late final GameWebSocketHandler wsHandler;

  bool get isMyTurn => currentPlayerId == currentTurnPlayerId;

  @override
  void initState() {
    super.initState();

    wsHandler = GameWebSocketHandler(
      url: 'wss://8015-213-170-209-87.ngrok-free.app/duel-masters-ws',
      // url: 'ws://localhost:8080/duel-masters-ws',
      currentPlayerId: currentPlayerId,
      onGameStateUpdate: (data) {
        _updateGameState(data);
      },
      onConnected: () {
        setState(() {
          isConnected = true;
        });
      },
      onMatchFound: (gameId) {
        setState(() {
          currentGameId = gameId;
          hasJoinedMatch = true;
        });
      },
    );



    wsHandler.connect();
  }

  @override
  void dispose() {
    shieldMoveController.dispose();
    wsHandler.disconnect();
    super.dispose();
  }

  void _updateGameState(Map<String, dynamic> responseBody) {
    final newTurnPlayerId = responseBody['currentTurnPlayerId'];
    final shieldTriggerFlagsJson = responseBody['shieldTriggersFlagsDto'] ?? {};

    shieldFlags = ShieldTriggersFlagsDto.fromJson(shieldTriggerFlagsJson);

    solarRayMustSelectCreature =
        shieldFlags?.solarRayMustSelectCreature ?? false;
    brainSerumMustDrawCards = shieldFlags?.brainSerumMustDrawCards ?? false;
    crystalMemoryMustDrawCard = shieldFlags?.crystalMemoryMustDrawCard ?? false;
    spiralGateMustSelectCreature = shieldFlags?.spiralGateMustSelectCreature ?? false;
    shieldTrigger = shieldFlags?.shieldTrigger ?? false;

    opponentHasBlocker = responseBody['opponentHasBlocker'];
    opponentSelectableCreatures =
        (responseBody['opponentSelectableCreatures'] as List? ?? [])
            .map((c) => CardModel.fromJson(c))
            .toList();

    final eachPlayerBattleZoneJson =
        shieldFlags?.eachPlayerBattleZone ?? {};

    final playerIdStr = currentPlayerId.toString();
    final opponentIdStr = opponentId.toString();

    spiralGatePlayerBattleZone =
    (eachPlayerBattleZoneJson[playerIdStr] as List? ?? [])
        .map((c) => CardModel.fromJson(c))
        .toList();

    spiralGateOpponentBattleZone =
    (eachPlayerBattleZoneJson[opponentIdStr] as List? ?? [])
        .map((c) => CardModel.fromJson(c))
        .toList();


    if (opponentHasBlocker) {
      Future.microtask(() => _showBlockerSelectionDialog());
    }

    if (shieldTrigger) {
      Future.microtask(() => _showShieldTriggerDialog());
    }

    if (spiralGateMustSelectCreature) {
      Future.microtask(() => _showDualCreatureSelectionOverlay());
    }

    if (brainSerumMustDrawCards) {
      Future.microtask(() => _showDrawFromDeckDialog(1, 2));
    }

    if (crystalMemoryMustDrawCard) {
      Future.microtask(() => _showDrawFromDeckDialog(1, 1));
    }

    if (!shieldTrigger && Navigator.canPop(context)) {
      Navigator.of(context).pop(); //dismiss for opponent
    }

    if (!opponentHasBlocker && Navigator.canPop(context)) {
      Navigator.of(context).pop(); //dismiss for opponent
    }

    if (previousTurnPlayerId != null &&
        previousTurnPlayerId != newTurnPlayerId) {
      final isMyTurn = newTurnPlayerId == currentPlayerId;
      _showTurnBanner(isMyTurn ? "Your Turn" : "Opponent's Turn");
    }

    if (responseBody['shieldTriggerCard'] != null) {
      shieldTriggerCard = CardModel.fromJson(responseBody['shieldTriggerCard']);
      shieldTrigger = true;
    }

    final zones = GameStateParser.parse(responseBody);

    setState(() {
      currentTurnPlayerId = newTurnPlayerId;
      previousTurnPlayerId = newTurnPlayerId;
      opponentId = responseBody['opponentId'];
      playedMana = responseBody['playedMana'];
      opponentHasBlocker = responseBody['opponentHasBlocker'];
      shieldTrigger = shieldFlags?.shieldTrigger ?? false;
      brainSerumMustDrawCards = shieldFlags?.brainSerumMustDrawCards ?? false;
      crystalMemoryMustDrawCard =
          shieldFlags?.crystalMemoryMustDrawCard ?? false;

      playerHand = zones.playerHand;
      playerDeck = zones.playerDeck;
      playerShields = zones.playerShields;
      playerManaZone = zones.playerManaZone;
      playerBattleZone = zones.playerBattleZone;
      playerGraveyard = zones.playerGraveyard;

      opponentHand = zones.opponentHand;
      opponentDeck = zones.opponentDeck;
      opponentShields = zones.opponentShields;
      opponentManaZone = zones.opponentManaZone;
      opponentBattleZone = zones.opponentBattleZone;
      opponentGraveyard = zones.opponentGraveyard;

      deckSize = playerDeck.length;
      opponentDeckSize = opponentDeck.length;
    });
  }

  Widget _showDualCreatureSelectionOverlay() {
    return DualCreatureSelectionOverlay(
      playerCreatures: spiralGatePlayerBattleZone,
      opponentCreatures: spiralGateOpponentBattleZone,
      selectedCreature: selectedCreature,
      onCardSelected: (card) {
        setState(() {
          selectedCreature = card;
        });
      },
      onConfirm: () {
        if (selectedCreature == null) return;

        wsHandler.useShieldTriggerCard(
          gameId: currentGameId,
          playerId: currentPlayerId,
          currentTurnPlayerId: currentTurnPlayerId,
          action: "CAST_SHIELD_TRIGGER",
          usingShieldTrigger: true,
          triggeredGameCardId: selectedCreature!.gameCardId,
        );
      },
    );
  }


  void _showTurnBanner(String text) {
    // final isMyTurn = text == "Your Turn";

    final overlay = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Center(
              child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMyTurn ? Colors.greenAccent : Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMyTurn ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(overlay);

    Future.delayed(Duration(seconds: 2), () {
      overlay.remove();
    });
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
                print(
                  "📩 Received game payload size: ${frame.body?.length ?? 0} bytes",
                );

                currentGameId = responseBody['gameId'];
                myPlayerTopic = responseBody['playerTopic'];
                currentTurnPlayerId = responseBody['currentTurnPlayerId'];
                opponentId = responseBody['opponentId'];
                playedMana = responseBody['playedMana'];

                final zones = GameStateParser.parse(responseBody);

                setState(() {
                  // Your zones
                  playerHand = zones.playerHand;
                  playerDeck = zones.playerDeck;
                  playerShields = zones.playerShields;
                  playerManaZone = zones.playerManaZone;
                  playerGraveyard = zones.playerGraveyard;
                  playerBattleZone = zones.playerBattleZone;

                  // Opponent zones
                  opponentHand = zones.opponentHand;
                  opponentDeck = zones.opponentDeck;
                  opponentShields = zones.opponentShields;
                  opponentManaZone = zones.opponentManaZone;
                  opponentGraveyard = zones.opponentGraveyard;
                  opponentBattleZone = zones.opponentBattleZone;

                  deckSize = playerDeck.length;
                  opponentDeckSize = opponentDeck.length;

                  hasJoinedMatch = true;
                });
              },
            );

            break;
          }
        }
      },
    );
  }

  void sendToMana(CardModel card) {
    if (!isMyTurn) {
      return;
    }
    if (playedMana) {
      showSnackBar("You can only send one card to mana per turn.");
      return;
    }
    wsHandler.sendCardToMana(
      gameId: currentGameId,
      playerId: currentPlayerId,
      triggeredGameCardId: card.gameCardId,
    );
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        glowingManaCardIds.remove(card.gameCardId);
      });
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _attackShieldOrCreature(CardModel attacker, CardModel target) {
    final bool? targetShield = target.shield;
    attackerId = attacker.gameCardId;
    wsHandler.attackShieldOrCreature(
      gameId: currentGameId,
      playerId: currentPlayerId,
      currentTurnPlayerId: currentTurnPlayerId,
      attackerId: attacker.gameCardId,
      targetId: target.gameCardId,
      targetShield: targetShield,
    );
  }

  void endTurn() {
    wsHandler.endTurn(
      gameId: currentGameId,
      playerId: currentPlayerId,
      currentTurnPlayerId: currentTurnPlayerId,
      opponentId: opponentId,
    );
  }

  void sendToGraveyard(CardModel card) {}

  void resetTurn() {}

  void _startAttackSelection(CardModel attacker) {
    if (!isMyTurn) return;
    setState(() {
      selectedAttacker = attacker;
      isSelectingAttackTarget = true;

      // Make opponent creatures glow (just like mana selection)
      glowAttackableShields =
          opponentShields
              .where((c) => c.canBeAttacked)
              .map((c) => c.gameCardId)
              .toSet();

      glowAttackableCreatures =
          opponentBattleZone
              .where((c) => c.canBeAttacked)
              .map((c) => c.gameCardId)
              .toSet();
    });
  }

  void _cancelAttackSelection() {
    setState(() {
      selectedAttacker = null;
      isSelectingAttackTarget = false;
      glowAttackableShields.clear();
      glowAttackableCreatures.clear();
    });
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
                  color:
                      currentTurnPlayerId == currentPlayerId
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
                      isConnected
                          ? () {
                            showSnackBar("🔍 Looking for opponent...");
                          }
                          : null,
                  icon: Icon(Icons.person_search),
                  label: Text("Search Match"),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: isMyTurn ? endTurn : null,
                  icon: Icon(Icons.refresh),
                  label: Text("End Turn"),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isSelectingAttackTarget) {
            _cancelAttackSelection();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/forest_board.png',
                fit: BoxFit.cover,
              ),
            ),
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
                        OpponentField(
                          hand: opponentHand,
                          shields: opponentShields,
                          manaZone: opponentManaZone,
                          graveyard: opponentGraveyard,
                          deckSize: opponentDeckSize,
                          opponentBattleZone: opponentBattleZone,
                          isSelectingAttackTarget: isSelectingAttackTarget,
                          selectedAttacker: selectedAttacker,
                          onTapManaZone:
                              () => _showCardZoneDialog(
                                "Opponent Mana",
                                opponentManaZone,
                                true,
                              ),
                          onTapHandCard:
                              (card) => _showFullScreenCardPreview(card),
                          onTapGraveyard:
                              () => _showCardZoneDialog(
                                "Opponent Graveyard",
                                opponentGraveyard,
                                true,
                              ),
                          glowAttackableShields: glowAttackableShields,
                          glowAttackableCreatures: glowAttackableCreatures,
                          // ✅
                          onAttack: (card) => _startAttackSelection(card),
                          // <- ADD THIS
                          onConfirmAttack: (targetCard) {
                            if (selectedAttacker == null) return;
                            _attackShieldOrCreature(
                              selectedAttacker!,
                              targetCard,
                            );
                          },
                        ),

                        SizedBox(height: 16),
                        SizedBox(height: 16),
                        PlayerField(
                          isMyTurn: isMyTurn,
                          hand: playerHand,
                          shields: playerShields,
                          manaZone: playerManaZone,
                          graveyard: playerGraveyard,
                          deckSize: deckSize,
                          onTapHandCard:
                              (card) => _showFullScreenCardPreview(card),
                          onTapManaCard:
                              (card) => _showFullScreenCardPreview(card),
                          onTapGraveyard:
                              () => _showCardZoneDialog(
                                "Graveyard",
                                playerGraveyard,
                              ),
                          onSummonHandCard:
                              (card) => _showManaSelectionDialog(card),
                          onSendToManaHandCard: (card) => sendToMana(card),
                          onAttack: (card) => _startAttackSelection(card),
                          playedMana: playedMana,
                          playerBattleZone: playerBattleZone,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (solarRayMustSelectCreature) _showCreatureSelectionOverlay(),
          ],
        ),
      ),
    );
  }



  Widget _showCreatureSelectionOverlay() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;

    return CreatureSelectionOverlay(
      isMyCreature: isMyCreature,
      shieldTriggerCard: shieldTriggerCard,
      opponentSelectableCreatures: opponentSelectableCreatures,
      selectedOpponentCreature: selectedOpponentCreature,
      onCardSelected: (card) {
        setState(() {
          selectedOpponentCreature = card;
        });
      },
      onConfirm: () {
        if (selectedOpponentCreature == null) return;

        wsHandler.useShieldTriggerCard(
          gameId: currentGameId,
          playerId: currentPlayerId,
          currentTurnPlayerId: currentTurnPlayerId,
          action: "CAST_SHIELD_TRIGGER",
          usingShieldTrigger: true,
          triggeredGameCardId: selectedOpponentCreature!.gameCardId,
        );
      },
    );
  }

  void _showBlockerSelectionDialog() {
    final isDefendingPlayer = currentTurnPlayerId != currentPlayerId;
    final blockers =
        playerBattleZone.where((c) => c.specialAbility == 'BLOCKER' &&
        !c.tapped).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        if (isDefendingPlayer) {
          // Defender: Select a blocker
          return BlockerSelectionDialog(
            blockers: blockers,
            onConfirm: (selected) {
              wsHandler.confirmBlockerSelection(
                gameId: currentGameId,
                playerId: currentPlayerId,
                currentTurnPlayerId: currentTurnPlayerId,
                action: "BLOCK",
                attackerId: "",
                targetId: selected.gameCardId,
                targetShield: false,
              );
            },
            onSkip: () {
              wsHandler.confirmNoBlocker(
                gameId: currentGameId,
                playerId: currentPlayerId,
                currentTurnPlayerId: currentTurnPlayerId,
                action: "BLOCK",
              );
            },
          );
        } else {
          // Attacker: Just wait and see this info
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: StyledDialogContainer(
              borderColor: Colors.greenAccent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Waiting for opponent to block...",
                    style: kDialogTitleStyle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "The defending player is choosing a blocker...",
                    style: kDialogSubtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (selectedAttacker != null) ...[
                    const Text(
                      "Attacking with:",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Image.asset(selectedAttacker!.imagePath, width: 80),
                    const SizedBox(height: 16),
                  ],
                  const CircularProgressIndicator(color: Colors.greenAccent),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showShieldTriggerDialog() {
    if (shieldTrigger && shieldTriggerCard != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => ShieldTriggerDialog(
              shieldTriggerCard: shieldTriggerCard!,
              isMyShieldTrigger: currentTurnPlayerId != currentPlayerId,
              onUseTrigger: () {
                wsHandler.useShieldTriggerCard(
                  gameId: currentGameId,
                  playerId: currentPlayerId,
                  currentTurnPlayerId: currentTurnPlayerId,
                  action: "CAST_SHIELD_TRIGGER",
                  usingShieldTrigger: true,
                );
              },
              onSkip: () {
                wsHandler.doNotUseShieldTriggerCard(
                  gameId: currentGameId,
                  playerId: currentPlayerId,
                  currentTurnPlayerId: currentTurnPlayerId,
                  action: "CAST_SHIELD_TRIGGER",
                  usingShieldTrigger: false,
                );
              },
            ),
      );
    }
  }

  void _showManaSelectionDialog(CardModel cardToSummon) {
    showDialog(
      context: context,
      builder:
          (_) => ManaSelectionDialog(
            cardToSummon: cardToSummon,
            manaCards: playerManaZone,
            onConfirm: (selectedIds) {
              summonCardWithMana(cardToSummon, selectedIds);
            },
          ),
    );
  }

  void summonCardWithMana(CardModel card, List<String> selectedManaIds) {
    if (!isMyTurn) return;
    wsHandler.summonWithMana(
      gameId: currentGameId,
      playerId: currentPlayerId,
      triggeredGameCardId: card.gameCardId,
      selectedManaCardIds: selectedManaIds,
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

  void _showDrawFromDeckDialog(int minSelection, int maxSelection) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => SelectCardsFromDeckDialog(
            deck: playerDeck,
            minSelection: minSelection,
            maxSelection: maxSelection,
            onConfirm: (selectedIds) {
              wsHandler.sendDrawCardsFromDeck(
                gameId: currentGameId,
                playerId: currentPlayerId,
                currentTurnPlayerId: currentTurnPlayerId,
                action: "CAST_SHIELD_TRIGGER",
                cardsChosen: selectedIds,
                shieldTriggerDecisionMade: true,
                usingShieldTrigger: true,
              );
            },
          ),
    );
  }
}
