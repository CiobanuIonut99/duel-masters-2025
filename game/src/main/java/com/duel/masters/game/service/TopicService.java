package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoOpponent;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoPlayer;

@AllArgsConstructor
@Service
@Slf4j
public class TopicService {
    private final GameStateStore gameStateStore;
    private final SimpMessagingTemplate simpMessagingTemplate;

    public void sendGameStatesToTopics(GameStateDto gameState) {
        gameStateStore.saveGameState(gameState);

        var topic1 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_1_TOPIC;
        var topic2 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_2_TOPIC;
        var gameState1 = getGameStateDtoPlayer(gameState, PLAYER_1_TOPIC);
        var gameState2 = getGameStateDtoOpponent(gameState, PLAYER_2_TOPIC);

        simpMessagingTemplate.convertAndSend(topic1, gameState1);
        simpMessagingTemplate.convertAndSend(topic2, gameState2);
        log.info("✅ Sent to topic1: {}", topic1);
        log.info("✅ Sent to topic2: {}", topic2);
    }
}
