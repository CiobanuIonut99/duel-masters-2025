package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
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
//    private final SimpMessagingTemplate simpMessagingTemplate;

    public void sendGameStatesToTopics(GameStateDto currentState) {
        gameStateStore.saveGameState(currentState);

        var topic1 = GAME_TOPIC + currentState.getGameId() + SLASH + PLAYER_1_TOPIC;
        var topic2 = GAME_TOPIC + currentState.getGameId() + SLASH + PLAYER_2_TOPIC;

        var gameState1 = getGameStateDtoPlayer(currentState, PLAYER_1_TOPIC);
        var gameState2 = getGameStateDtoOpponent(currentState, PLAYER_2_TOPIC);

//        simpMessagingTemplate.convertAndSend(topic1, gameState1);
//        simpMessagingTemplate.convertAndSend(topic2, gameState2);
        log.info("✅ Sent to topic1: {}", topic1);
        log.info("✅ Sent to topic2: {}", topic2);
    }
}
