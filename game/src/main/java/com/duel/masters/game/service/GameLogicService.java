package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.constant.Constant.PLAYER_2_TOPIC;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDto;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {

    private final SimpMessagingTemplate simpMessagingTemplate;

    public void doAction(GameStateDto gameStateDto) {
        switch (gameStateDto.getAction()) {
            case "SEND_CARD_TO_MANA" -> {
                sendCardToMana(gameStateDto.getPlayerHand(),
                        gameStateDto.getTriggeredGameCardId(),
                        gameStateDto.getPlayerManaZone());
                sendGameStatesToTopics(gameStateDto);
            }
        }
    }

    private void sendCardToMana(List<CardDto> hand, String triggeredGameCardId, List<CardDto> manaZone) {
        for (CardDto cardDto : hand) {
            if (cardDto.getGameCardId().equals(triggeredGameCardId)) {
                manaZone.add(cardDto);
                hand.remove(cardDto);
            }
        }
    }

    private void sendGameStatesToTopics(GameStateDto gameState) {
        var gameState1 = getGameStateDto(gameState, gameState.getPlayerTopic());
        var gameState2 = getGameStateDto(gameState, gameState.getPlayerTopic());
        var topic1 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_1_TOPIC;
        var topic2 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_2_TOPIC;
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                simpMessagingTemplate.convertAndSend(topic1, gameState1);
                simpMessagingTemplate.convertAndSend(topic2, gameState2);
                log.info("✅ Sent to topic1: {}", topic1);
                log.info("✅ Sent to topic2: {}", topic2);
            }
        }, 2000);
    }
}
