import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../dialogs/blocker_selection_dialog.dart';
import '../dialogs/creature_selection_destroy_under4000_dialog.dart';
import '../dialogs/creature_selection_dialog.dart';
import '../dialogs/creature_selection_put_in_mana_zone.dart';
import '../dialogs/dual_creature_selection_list.dart';
import '../dialogs/graveyard_creature_selection_dialog.dart';
import '../dialogs/mana_selection_dialog.dart';
import '../dialogs/select_card_count_dialog.dart';
import '../dialogs/select_cards_from_deck_dialog.dart';
import '../dialogs/select_creature_from_deck_dialog.dart';
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

  List<CardModel> playerBattlezoneFromEachPlayerBattlezone = [];
  List<CardModel> opponentBattlezoneFromEachPlayerBattlezone = [];
  List<CardModel> opponentUnder4000Creatures = [];
  List<CardModel> playerCreatureDeck = [];
  List<CardModel> playerCreatureGraveyard = [];
  List<CardModel> selectedCreatures = [];

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

  CardModel? lastSelectedCreatureFromDeck;

  bool isConnected = false;
  bool hasDismissedChosenCard = false;

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
  bool terrorPitMustSelectCreature = false;
  bool tornadoFlameMustSelectCreature = false;
  bool spiralGateMustSelectCreature = false;
  bool naturalSnareMustSelectCreature = false;
  bool brainSerumMustDrawCards = false;
  bool dimensionGateMustDrawCard = false;
  bool crystalMemoryMustDrawCard = false;
  bool darkReversalMustSelectCreature = false;
  bool aquaSniperMustSelectCreature = false;

  List<CardModel> opponentSelectableCreatures = [];
  CardModel? selectedOpponentCreature;
  CardModel? selectCreatureFromGraveyard;

  double hoverScale = 1.0;

  StompUnsubscribe? sub1;
  StompUnsubscribe? sub2;

  late StompClient stompClient;
  late final GameWebSocketHandler wsHandler;

  bool isTurnBannerVisible = false;

  bool get isMyTurn => currentPlayerId == currentTurnPlayerId;

  @override
  void initState() {
    super.initState();

    wsHandler = GameWebSocketHandler(
      // url: 'ws://localhost:8080/duel-masters-ws',
      url: 'wss://f63a-79-115-136-178.ngrok-free.app/duel-masters-ws',
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
    final shieldTriggerFlagsJson = responseBody['shieldTriggersFlagsDto'];

    if (shieldTriggerFlagsJson != null) {
      shieldFlags = ShieldTriggersFlagsDto.fromJson(shieldTriggerFlagsJson);

      solarRayMustSelectCreature =
          shieldFlags?.solarRayMustSelectCreature ?? false;
      brainSerumMustDrawCards = shieldFlags?.brainSerumMustDrawCards ?? false;
      dimensionGateMustDrawCard =
          shieldFlags?.dimensionGateMustDrawCard ?? false;
      crystalMemoryMustDrawCard =
          shieldFlags?.crystalMemoryMustDrawCard ?? false;
      naturalSnareMustSelectCreature =
          shieldFlags?.naturalSnareMustSelectCreature ?? false;
      spiralGateMustSelectCreature =
          shieldFlags?.spiralGateMustSelectCreature ?? false;
      aquaSniperMustSelectCreature =
          shieldFlags?.aquaSniperMustSelectCreature ?? false;
      darkReversalMustSelectCreature =
          shieldFlags?.darkReversalMustSelectCreature ?? false;
      terrorPitMustSelectCreature =
          shieldFlags?.terrorPitMustSelectCreature ?? false;
      tornadoFlameMustSelectCreature =
          shieldFlags?.tornadoFlameMustSelectCreature ?? false;
      shieldTrigger = shieldFlags?.shieldTrigger ?? false;
      opponentUnder4000Creatures =
          shieldFlags?.opponentUnder4000Creatures ?? [];
      playerCreatureDeck = shieldFlags?.playerCreatureDeck ?? [];
      playerCreatureGraveyard = shieldFlags?.playerCreatureGraveyard ?? [];
    }

    final eachPlayerBattleZoneJson = shieldFlags?.eachPlayerBattleZone ?? {};
    final playerIdStr = currentPlayerId.toString();
    final opponentIdStr = opponentId.toString();

    playerBattlezoneFromEachPlayerBattlezone =
        (eachPlayerBattleZoneJson[playerIdStr] as List? ?? [])
            .map((c) => CardModel.fromJson(c))
            .toList();

    opponentBattlezoneFromEachPlayerBattlezone =
        (eachPlayerBattleZoneJson[opponentIdStr] as List? ?? [])
            .map((c) => CardModel.fromJson(c))
            .toList();

    if (responseBody.containsKey('opponentHasBlocker')) {
      opponentHasBlocker = responseBody['opponentHasBlocker'];
    }

    if (responseBody.containsKey('opponentSelectableCreatures')) {
      opponentSelectableCreatures =
          (responseBody['opponentSelectableCreatures'] as List? ?? [])
              .map((c) => CardModel.fromJson(c))
              .toList();
    }

    if (opponentHasBlocker) {
      Future.microtask(() => _showBlockerSelectionDialog());
    }

    if (shieldTrigger) {
      Future.microtask(() => _showShieldTriggerDialog());
    }

    if (dimensionGateMustDrawCard) {
      Future.microtask(() => _showDrawCreatureFromDeckDialog());
    }

    if (brainSerumMustDrawCards) {
      Future.microtask(() => _showCountCardDialog());
    }

    if (crystalMemoryMustDrawCard) {
      Future.microtask(() => _showDrawFromDeckDialog(1, 1));
    }

    if (!shieldTrigger && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    if (!opponentHasBlocker && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    if (previousTurnPlayerId != null &&
        previousTurnPlayerId != newTurnPlayerId) {
      final isMyTurn = newTurnPlayerId == currentPlayerId;

      setState(() {
        lastSelectedCreatureFromDeck = null;
      });

      _showTurnBanner(isMyTurn ? "Your Turn" : "Opponent's Turn");
    }

    if (responseBody.containsKey('shieldTriggerCard')) {
      shieldTriggerCard = CardModel.fromJson(responseBody['shieldTriggerCard']);
      shieldTrigger = true;
    }

    if (shieldFlags?.lastSelectedCreatureFromDeck != null) {
      if (!hasDismissedChosenCard &&
          (lastSelectedCreatureFromDeck == null ||
              lastSelectedCreatureFromDeck!.gameCardId !=
                  shieldFlags!.lastSelectedCreatureFromDeck!.gameCardId)) {
        setState(() {
          lastSelectedCreatureFromDeck =
              shieldFlags!.lastSelectedCreatureFromDeck;
        });
      }
    } else {
      setState(() {
        lastSelectedCreatureFromDeck = null;
        hasDismissedChosenCard = false;
      });
    }

    setState(() {
      if (responseBody.containsKey('currentTurnPlayerId')) {
        currentTurnPlayerId = newTurnPlayerId;
        previousTurnPlayerId = newTurnPlayerId;
      }

      if (responseBody.containsKey('opponentId')) {
        opponentId = responseBody['opponentId'];
      }

      if (responseBody.containsKey('playedMana')) {
        playedMana = responseBody['playedMana'];
      }

      final zones = GameStateParser.parse(responseBody);

      if (zones.playerHand != null) playerHand = zones.playerHand!;
      if (zones.playerDeck != null) playerDeck = zones.playerDeck!;
      if (zones.playerShields != null) playerShields = zones.playerShields!;
      if (zones.playerManaZone != null) playerManaZone = zones.playerManaZone!;
      if (zones.playerBattleZone != null)
        playerBattleZone = zones.playerBattleZone!;
      if (zones.playerGraveyard != null)
        playerGraveyard = zones.playerGraveyard!;

      if (zones.opponentHand != null) opponentHand = zones.opponentHand!;
      if (zones.opponentDeck != null) opponentDeck = zones.opponentDeck!;
      if (zones.opponentShields != null)
        opponentShields = zones.opponentShields!;
      if (zones.opponentManaZone != null)
        opponentManaZone = zones.opponentManaZone!;
      if (zones.opponentBattleZone != null)
        opponentBattleZone = zones.opponentBattleZone!;
      if (zones.opponentGraveyard != null)
        opponentGraveyard = zones.opponentGraveyard!;

      deckSize = playerDeck.length;
      opponentDeckSize = opponentDeck.length;
    });
  }

  Widget _showDualCreatureSelectionOverlay() {
    return DualCreatureSelectionOverlay(
      playerCreatures: playerBattlezoneFromEachPlayerBattlezone,
      opponentCreatures: opponentBattlezoneFromEachPlayerBattlezone,
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

  Widget _showDualCreatureListSelectionOverlay() {
    return DualCreatureListSelectionOverlay(
      playerCreatures: playerBattlezoneFromEachPlayerBattlezone,
      opponentCreatures: opponentBattlezoneFromEachPlayerBattlezone,
      selectedCreatures: selectedCreatures,
      onCardToggle: (card) {
        setState(() {
          if (selectedCreatures.any((c) => c.gameCardId == card.gameCardId)) {
            selectedCreatures.removeWhere(
              (c) => c.gameCardId == card.gameCardId,
            );
          } else {
            if (selectedCreatures.length < 2) {
              selectedCreatures.add(card);
            }
          }
        });
      },
      onConfirm: () {
        final selectedIds = selectedCreatures.map((c) => c.gameCardId).toList();
        wsHandler.sendAquaSniperSelection(
          gameId: currentGameId,
          playerId: currentPlayerId,
          currentTurnPlayerId: currentTurnPlayerId,
          action: "SUMMON_TO_BATTLE_ZONE",
          cardsChosen: selectedIds,
          shieldTriggerDecisionMade: true,
          usingShieldTrigger: true,
        );

        setState(() {
          selectedCreatures.clear();
        });
      },
    );
  }

  void _showTurnBanner(String text) {
    setState(() {
      isTurnBannerVisible = true;
    });

    final overlay = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Center(
              child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMyTurn ? Colors.greenAccent : Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMyTurn ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 20, // smaller font
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
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
      setState(() {
        isTurnBannerVisible = false;
      });
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
                  playerHand = zones.playerHand ?? [];
                  playerDeck = zones.playerDeck ?? [];
                  playerShields = zones.playerShields ?? [];
                  playerManaZone = zones.playerManaZone ?? [];
                  playerGraveyard = zones.playerGraveyard ?? [];
                  playerBattleZone = zones.playerBattleZone ?? [];

                  opponentHand = zones.opponentHand ?? [];
                  opponentDeck = zones.opponentDeck ?? [];
                  opponentShields = zones.opponentShields ?? [];
                  opponentManaZone = zones.opponentManaZone ?? [];
                  opponentGraveyard = zones.opponentGraveyard ?? [];
                  opponentBattleZone = zones.opponentBattleZone ?? [];

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
                'assets/backgrounds/ice_board.png',
                // 'assets/backgrounds/forest_board.png',
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
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 12,
                      right: 12,
                    ),
                    child: Transform(
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            // ..setEntry(0, 2, 0.0015)
                            ..rotateX(-0.15), // slight tilt
                      // ..rotateX(-0.15), // slight tilt
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 0.85,
                            child: OpponentField(
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
                          ),
                          Spacer(),
                          SizedBox(height: 16),
                          Transform.scale(
                            scale: 0.85,
                            child: PlayerField(
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
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (solarRayMustSelectCreature) _showCreatureSelectionOverlay(),
            if (terrorPitMustSelectCreature)
              _showDestroyCreatureSelectionOverlay(),
            if (tornadoFlameMustSelectCreature)
              _showDestroyCreatureUnder4000SelectionOverlay(),
            if (darkReversalMustSelectCreature)
              _showGraveyardCreatureSelectionOverlay(),
            if (spiralGateMustSelectCreature)
              _showDualCreatureSelectionOverlay(),
            if (aquaSniperMustSelectCreature)
              _showDualCreatureListSelectionOverlay(),
            if (naturalSnareMustSelectCreature)
              _showCreatureSelectionForManaZoneOverlay(),
            if (lastSelectedCreatureFromDeck != null &&
                currentTurnPlayerId == currentPlayerId &&
                !hasDismissedChosenCard)
              _showChosenCard(),

            _showTurnLabel(),
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

  Widget _showDestroyCreatureSelectionOverlay() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;

    return CreatureSelectionOverlay(
      isMyCreature: isMyCreature,
      shieldTriggerCard: shieldTriggerCard,
      opponentSelectableCreatures: opponentBattleZone,
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

  Widget _showCreatureSelectionForManaZoneOverlay() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;

    return CreatureSelectionForManaZoneOverlay(
      isMyCreature: isMyCreature,
      shieldTriggerCard: shieldTriggerCard,
      opponentSelectableCreatures: opponentBattleZone,
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

  Widget _showDestroyCreatureUnder4000SelectionOverlay() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;

    return DestroyCreatureUnder4000SelectionOverlay(
      isMyCreature: isMyCreature,
      shieldTriggerCard: shieldTriggerCard,
      opponentUnder4000Creatures: opponentUnder4000Creatures,
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

  Widget _showGraveyardCreatureSelectionOverlay() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;

    return GraveyardCreatureSelectionOverlay(
      isMyCreature: isMyCreature,
      shieldTriggerCard: shieldTriggerCard,
      opponentSelectableCreatures: playerCreatureGraveyard,
      selectedOpponentCreature: selectCreatureFromGraveyard,
      onCardSelected: (card) {
        setState(() {
          selectCreatureFromGraveyard = card;
        });
      },
      onConfirm: () {
        if (selectCreatureFromGraveyard == null) return;

        wsHandler.useShieldTriggerCard(
          gameId: currentGameId,
          playerId: currentPlayerId,
          currentTurnPlayerId: currentTurnPlayerId,
          action: "CAST_SHIELD_TRIGGER",
          usingShieldTrigger: true,
          triggeredGameCardId: selectCreatureFromGraveyard!.gameCardId,
        );
      },
    );
  }

  void _showBlockerSelectionDialog() {
    final isDefendingPlayer = currentTurnPlayerId != currentPlayerId;
    final blockers =
        playerBattleZone
            .where((c) => c.specialAbility == 'BLOCKER' && !c.tapped)
            .toList();

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
                cardsDrawn: selectedIds.length,
                shieldTriggerDecisionMade: true,
                usingShieldTrigger: true,
              );
            },
          ),
    );
  }

  void _showCountCardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => SelectCardCountDialog(
            onConfirm: (count) {
              wsHandler.sendDrawCardsFromDeck(
                gameId: currentGameId,
                playerId: currentPlayerId,
                currentTurnPlayerId: currentTurnPlayerId,
                action: "CAST_SHIELD_TRIGGER",
                cardsChosen: ["nonemptylist"],
                cardsDrawn: count,
                shieldTriggerDecisionMade: true,
                usingShieldTrigger: true,
              );
            },
            onCancel: () {
              // Optional: handle cancel, or do nothing
            },
          ),
    );
  }

  void _showDrawCreatureFromDeckDialog() {
    final isMyCreature = currentTurnPlayerId != currentPlayerId;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => SelectCreatureFromDeckDialog(
            isMyCreature: isMyCreature,
            deck: playerCreatureDeck,
            onConfirm: (selectedIds) {
              wsHandler.sendDrawCardsFromDeck(
                gameId: currentGameId,
                playerId: currentPlayerId,
                currentTurnPlayerId: currentTurnPlayerId,
                action: "CAST_SHIELD_TRIGGER",
                cardsChosen: selectedIds,
                cardsDrawn: selectedIds.length,
                shieldTriggerDecisionMade: true,
                usingShieldTrigger: true,
              );
            },
          ),
    );
  }

  Positioned _showChosenCard() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25,
      left: MediaQuery.of(context).size.width * 0.5 - 100,
      child: AnimatedOpacity(
        opacity: 1,
        duration: Duration(milliseconds: 500),
        child: Container(
          width: 220,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ⭐ Sparkle particles
              Positioned(
                top: -10,
                left: -10,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.purpleAccent,
                  size: 20,
                ),
              ),
              Positioned(
                bottom: -10,
                left: 0,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
              ),
              // Main content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Chosen Creature",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      lastSelectedCreatureFromDeck!.imagePath,
                      width: 120,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    lastSelectedCreatureFromDeck!.name,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        hasDismissedChosenCard = true;
                        lastSelectedCreatureFromDeck = null;
                      });
                    },
                    child: Text(
                      "Dismiss",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned _showTurnLabel() {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 30,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Turn label
          !isTurnBannerVisible
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentTurnPlayerId == currentPlayerId
                      ? "Your Turn"
                      : "Opponent's Turn",
                  style: TextStyle(
                    color:
                        currentTurnPlayerId == currentPlayerId
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    fontSize: 14, // smaller font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : SizedBox(width: 0),

          // Right side: End Turn button
          ElevatedButton.icon(
            onPressed: isMyTurn ? endTurn : null,
            icon: Icon(Icons.refresh),
            label: Text("End Turn"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
