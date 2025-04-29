package com.duel.masters.game.config.unity;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.GameLogicService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import static com.duel.masters.game.util.ObjectMapperUtil.convertToGameStateDto;

@Slf4j
@Component
public class GameWebSocketHandler extends TextWebSocketHandler {
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final Map<Long, WebSocketSession> playerSessions = new ConcurrentHashMap<>();
    private final GameLogicService gameLogicService;

    public GameWebSocketHandler(GameLogicService gameLogicService) {
        this.gameLogicService = gameLogicService;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        log.info("Websocket connection established : {}, {}", session.getId(), session.isOpen());
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.info("Websocket message received: {}", message.getPayload());
        Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
        handleAction(session, convertToGameStateDto(payload));
    }

    private void handleAction(WebSocketSession session, GameStateDto incomingState) {
        log.info("⚡ Action received: {}", incomingState);
        playerSessions.putIfAbsent(incomingState.getPlayerDto().getId(), session);
        gameLogicService.act(incomingState, this);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        log.info("❌ WebSocket disconnected: {}, status: {}", session.getId(), status.toString());
        playerSessions.remove(session.getId());
        // Remove from playerSessions if you track them later
    }

    private void sendToClient(WebSocketSession session, Object response) throws Exception {
        String json = objectMapper.writeValueAsString(response);
        session.sendMessage(new TextMessage(json));
    }

    public WebSocketSession getSessionForPlayer(Long playerId) {
        return playerSessions.get(playerId);
    }

}
