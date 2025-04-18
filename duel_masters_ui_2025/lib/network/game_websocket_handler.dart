import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../models/card_model.dart';

typedef GameStateCallback = void Function(Map<String, dynamic>);

class GameWebSocketHandler {
  final String url;
  final int currentPlayerId;
  final GameStateCallback onGameStateUpdate;
  final void Function(String gameId, String playerTopic) onMatchFound;
  final void Function()? onConnected;

  late final StompClient stompClient;

  GameWebSocketHandler({
    required this.url,
    required this.currentPlayerId,
    required this.onGameStateUpdate,
    required this.onMatchFound,
    required this.onConnected,
  }) {
    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        heartbeatOutgoing: Duration(seconds: 10), // 🫀 send heartbeat every 10s
        heartbeatIncoming: Duration(seconds: 10), // 🫀 expect heartbeat every 10s

      ),
    );
  }

  void connect() {
    stompClient.activate();
  }

  void disconnect() {
    stompClient.deactivate();
  }

  void _onConnect(StompFrame frame) {
    isConnected = true;
    print("✅ Connected to WebSocket");

    if (onConnected != null) {
      onConnected!();
    }

    stompClient.subscribe(
      destination: '/topic/matchmaking',
      callback: (frame) {
        final List<dynamic> gameStates = jsonDecode(frame.body!);

        for (var state in gameStates) {
          if (state['playerId'] == currentPlayerId) {
            onMatchFound(state['gameId'], state['playerTopic']);
            _subscribeToGame(state['gameId'], state['playerTopic']);
            break;
          }
        }
      },
    );
  }

  void _subscribeToGame(String gameId, String playerTopic) {
    stompClient.subscribe(
      destination: '/topic/game/$gameId/$playerTopic',
      callback: (frame) {
        final responseBody = jsonDecode(frame.body!);
        onGameStateUpdate(responseBody);
      },
    );
  }

  void sendAction(String destination, Map<String, dynamic> payload) {
    if (stompClient.connected) {
      stompClient.send(destination: destination, body: jsonEncode(payload));
    }
  }

  bool isConnected = false;

  void waitAndSearchForMatch({
    required List<CardModel> hand,
    required List<CardModel> shields,
    required List<CardModel> deck,
    required VoidCallback onSearching,
  }) {
    if (isConnected) {
      searchForMatch(
        hand: hand,
        shields: shields,
        deck: deck,
        onSearching: onSearching,
      );
      return;
    }

    print("⏳ Waiting for WebSocket to connect...");

    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (isConnected) {
        timer.cancel();
        print("✅ WebSocket connected! Searching for match...");
        searchForMatch(
          hand: hand,
          shields: shields,
          deck: deck,
          onSearching: onSearching,
        );
      }
    });
  }

  void searchForMatch({
    required List<CardModel> hand,
    required List<CardModel> shields,
    required List<CardModel> deck,
    required VoidCallback onSearching,
  }) {
    if (!stompClient.connected) return;

    final payload = {
      "id": currentPlayerId,
      "username": "player_$currentPlayerId",
      "playerHand": hand.map((c) => c.toJson()).toList(),
      "playerShields": shields.map((c) => c.toJson()).toList(),
      "playerDeck": deck.map((c) => c.toJson()).toList(),
    };

    stompClient.send(
      destination: '/duel-masters/game/start',
      body: jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );

    print(
      "🔄 Searching for match as player_$currentPlayerId ($currentPlayerId)",
    );

    onSearching();
  }

  void sendCardToMana({
    required String? gameId,
    required int playerId,
    required String? playerTopic,
    required String triggeredGameCardId,
    required VoidCallback onAlreadyPlayedMana,
    required VoidCallback onSucces,
  }) {
    if (!stompClient.connected) return;

    final payload = {
      "gameId": gameId,
      "playerId": playerId,
      "playerTopic": playerTopic,
      "action": "SEND_CARD_TO_MANA",
      "triggeredGameCardId": triggeredGameCardId,
    };

    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode(payload),
    );
  }

  void summonWithMana({
    required String? gameId,
    required int playerId,
    required String? playerTopic,
    required String triggeredGameCardId,
    required List<String> selectedManaCardIds,
    required VoidCallback onSucces,
  }) {
    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode({
        "gameId": gameId,
        "playerId": playerId,
        "playerTopic": playerTopic,
        "action": "SUMMON_TO_BATTLE_ZONE",
        "triggeredGameCardId": triggeredGameCardId,
        "triggeredGameCardIds": selectedManaCardIds,
      }),
    );

    onSucces();
  }

  void endTurn({
    required String? gameId,
    required int playerId,
    required int opponentId,
    required int? currentTurnPlayerId,
    required String? action,
    required VoidCallback onSuccess,
  }) {
    if (!stompClient.connected) return;

    final payload = {
      "gameId": gameId,
      "playerId": currentPlayerId,
      "opponentId": opponentId,
      "currentTurnPlayerId": currentTurnPlayerId,
      "action": "END_TURN",
    };
    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode(payload),
    );
  }

  void confirmBlockerSelection({
    required String? gameId,
    required int playerId,
    required int? currentTurnPlayerId,
    required String? action,
    required targetShield,
    required String attackerId,
    required String targetId,
    required Null Function() onSuccess,
  }) {
    if (!stompClient.connected) return;
    final payload = {
      "gameId": gameId,
      "playerId": currentPlayerId,
      "currentTurnPlayerId": currentTurnPlayerId,
      "action": action,
      "attackerId": attackerId,
      "targetId": targetId,
      "targetShield": targetShield,
      "hasSelectedBlocker": true,
    };
    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode(payload),
    );
  }

  void confirmNoBlocker({
    required String? gameId,
    required String? action,
    required int playerId,
    required int? currentTurnPlayerId,
    required void Function() onSuccess,
  }) {
    if (!stompClient.connected) return;
    final payload = {
      "gameId": gameId,
      "action": action,
      "playerId": currentPlayerId,
      "currentTurnPlayerId": currentTurnPlayerId,
      "hasSelectedBlocker": false,
    };
    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode(payload),
    );
  }

  void attackShieldOrCreature({
    required String? gameId,
    required int playerId,
    required int? currentTurnPlayerId,
    required String? action,
    required targetShield,
    required String attackerId,
    required String targetId,
    required Null Function() onSucces,
  }) {
    if (!stompClient.connected) return;
    final payload = {
      "gameId": gameId,
      "playerId": currentPlayerId,
      "currentTurnPlayerId": currentTurnPlayerId,
      "action": "ATTACK",
      "attackerId": attackerId,
      "targetId": targetId,
      "targetShield": targetShield,
    };
    stompClient.send(
      destination: '/duel-masters/game/action',
      body: jsonEncode(payload),
    );
  }
}
