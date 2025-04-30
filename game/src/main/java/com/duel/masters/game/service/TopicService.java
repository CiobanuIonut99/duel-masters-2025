package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoOpponent;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoPlayer;

@AllArgsConstructor
@Service
@Slf4j
public class TopicService {
    private final GameStateStore gameStateStore;
    private final ObjectMapper objectMapper;

    public void sendGameStatesToTopics(GameStateDto currentState, GameWebSocketHandler webSocketHandler) {
        gameStateStore.saveGameState(currentState);

        var gameStatePlayer = getGameStateDtoPlayer(currentState);
        var gameStateOpponent = getGameStateDtoOpponent(currentState);


        WebSocketSession playerSession = webSocketHandler.getSessionForPlayer(currentState.getPlayerId());
        WebSocketSession opponentSession = webSocketHandler.getSessionForPlayer(currentState.getOpponentId());

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

    }
}
