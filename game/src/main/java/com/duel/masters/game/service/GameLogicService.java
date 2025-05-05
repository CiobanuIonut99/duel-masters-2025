package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDto;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {

    private final ActionsService actionsService;
    private final GameStateStore gameStateStore;
    private final InitialStateService initialStateService;
    private final MatchmakingService matchmakingService;
    private final ObjectMapper objectMapper;


    public void act(GameStateDto incomingState, GameWebSocketHandler webSocketHandler, WebSocketSession session) {
        if (START.equalsIgnoreCase(incomingState.getAction())) {

            webSocketHandler.getPlayerSessions().putIfAbsent(incomingState.getPlayerDto().getId(), session);
            startGame(incomingState.getPlayerDto(), webSocketHandler);

        } else {
            var currentState = gameStateStore.getGameState(incomingState.getGameId());

            if (currentState == null) {
                log.error("❌ No game state found for gameId: {}", incomingState.getGameId());
                return;
            }

            log.info("⚡ Action received: {}, for player : {}"
                    , incomingState.getAction(),
                    incomingState.getPlayerId());
            switch (incomingState.getAction()) {
                case BLOCK -> actionsService.block(currentState, incomingState,webSocketHandler);
                case ATTACK -> actionsService.attack(currentState, incomingState,webSocketHandler);
                case END_TURN -> actionsService.endTurn(currentState, incomingState,webSocketHandler);
                case SEND_CARD_TO_MANA -> actionsService.summonCardToManaZone(currentState, incomingState,webSocketHandler);
                case SUMMON_TO_BATTLE_ZONE -> actionsService.summonToBattleZone(currentState, incomingState,webSocketHandler);
                case CAST_SHIELD_TRIGGER -> actionsService.triggerShieldTriggerLogic(currentState, incomingState,webSocketHandler);
            }
        }
    }

    public void startGame(PlayerDto playerDto, GameWebSocketHandler gameWebSocketHandler) {
        log.info(playerDto.getUsername().concat(" is searching for an opponent  ..."));

        setPlayerData(playerDto);

        matchmakingService
                .tryMatchPlayer(playerDto)
                .ifPresentOrElse(
                        playerList -> {
                            String gameId = UUID.randomUUID().toString();
                            var player = playerList.get(0);
                            var opponent = playerList.get(1);

                            var randomPlayer = ThreadLocalRandom.current().nextInt(1, 3);
                            var isPlayer1Chosen = randomPlayer == 1;

                            var gameStatePlayer = getGameStateDto(gameId, player, opponent, isPlayer1Chosen);
                            var gameStateOpponent = getGameStateDto(gameId, opponent, player, !isPlayer1Chosen);

                            gameStateStore.saveGameState(gameStatePlayer);

                            sendGameStatesToTopics(gameStatePlayer, gameStateOpponent, player, opponent,gameWebSocketHandler);
                        },
                        () -> {
                            log.info("🕒 No opponent yet, broadcasting waiting player {}", playerDto.getUsername());
                        }
                );

    }

    private void setPlayerData(PlayerDto playerDto) {
        var initialState = initialStateService.getInitialState();
        playerDto.setPlayerDeck(initialState.getDeck());
        playerDto.setPlayerHand(initialState.getHand());
        playerDto.setPlayerShields(initialState.getShields());

        log.info("Set data to player {}", playerDto.getUsername());
        log.info("Set deck to player {}", playerDto.getPlayerDeck().size());
        log.info("Set shields to player {}", playerDto.getPlayerShields().size());
        log.info("Set hand to player {}", playerDto.getPlayerHand().size());
    }

    private void sendGameStatesToTopics(GameStateDto gameStatePlayer,
                                        GameStateDto gameStateOpponent,
                                        PlayerDto player,
                                        PlayerDto opponent,
                                        GameWebSocketHandler gameWebSocketHandler) {
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                WebSocketSession playerSession = gameWebSocketHandler.getSessionForPlayer(player.getId());
                WebSocketSession opponentSession = gameWebSocketHandler.getSessionForPlayer(opponent.getId());

                try {

                    String jsonPlayer = objectMapper.writeValueAsString(gameStatePlayer);
                    String jsonOpponent = objectMapper.writeValueAsString(gameStateOpponent);

                    if (playerSession != null && playerSession.isOpen()) {
                        playerSession.sendMessage(new TextMessage(jsonPlayer));
                    }
                    if (opponentSession != null && opponentSession.isOpen()) {
                        opponentSession.sendMessage(new TextMessage(jsonOpponent));
                    }

                    log.info("✅ Sent GameStateDto to both players.");
                } catch (Exception e) {
                    log.error("❌ Failed to send game state via raw WebSocket: {}", e.getMessage());
                }

                log.info("🎮 Matched players {} vs {}", player.getId(), opponent.getId());
            }
        }, 200);
    }
}
