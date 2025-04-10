package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoOpponent;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoPlayer;
import static com.duel.masters.game.util.ObjectMapperUtil.convertToGameStateDto;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {

    private final GameStateStore gameStateStore;
    private final SimpMessagingTemplate simpMessagingTemplate;

    public void doAction(Map<String, Object> payload) {
        var incomingDto = convertToGameStateDto(payload);
        var currentState = gameStateStore.getGameState(incomingDto.getGameId());

        if (currentState == null) {
            log.error("❌ No game state found for gameId: {}", incomingDto.getGameId());
            return;
        }

        boolean isPlayer1 = currentState.getPlayerId().equals(incomingDto.getPlayerId());
        var hand = isPlayer1 ? currentState.getPlayerHand() : currentState.getOpponentHand();
        var manaZone = isPlayer1 ? currentState.getPlayerManaZone() : currentState.getOpponentManaZone();
        var deck = isPlayer1 ? currentState.getPlayerDeck() : currentState.getOpponentDeck();
        var graveyard = isPlayer1 ? currentState.getPlayerGraveyard() : currentState.getOpponentGraveyard();
        var battleZone = isPlayer1 ? currentState.getPlayerBattleZone() : currentState.getOpponentBattleZone();

        switch (incomingDto.getAction()) {
            case "SEND_CARD_TO_MANA" -> {
                sendCardToMana(hand, incomingDto.getTriggeredGameCardId(), manaZone);
                gameStateStore.saveGameState(currentState);
                sendGameStatesToTopics(currentState);
            }
            case "END_TURN" -> {
                if (isPlayer1) {
                    currentState.setCurrentTurnPlayerId(incomingDto.getOpponentId());
                } else {
                    currentState.setCurrentTurnPlayerId(incomingDto.getPlayerId());
                }
                sendGameStatesToTopics(currentState);
                gameStateStore.saveGameState(currentState);
            }

        }
    }

    private void sendCardToMana(List<CardDto> hand, String triggeredGameCardId, List<CardDto> manaZone) {
        CardDto toMoveAndRemove = null;
        for (CardDto cardDto : hand) {
            if (cardDto.getGameCardId().equals(triggeredGameCardId)) {
                toMoveAndRemove = cardDto;
                break;
            }
        }
        hand.remove(toMoveAndRemove);
        manaZone.add(toMoveAndRemove);
    }

    private void sendGameStatesToTopics(GameStateDto gameState) {
        gameStateStore.saveGameState(gameState);

        var topic1 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_1_TOPIC;
        var topic2 = GAME_TOPIC + gameState.getGameId() + SLASH + PLAYER_2_TOPIC;
        var gameState1 = getGameStateDtoPlayer(gameState, PLAYER_1_TOPIC);
        var gameState2 = getGameStateDtoOpponent(gameState, PLAYER_2_TOPIC);

        log.info("SENDING GAME STATE 1 : {}", gameState1);
        log.info("SENDING GAME STATE 2 : {}", gameState2);
        simpMessagingTemplate.convertAndSend(topic1, gameState1);
        simpMessagingTemplate.convertAndSend(topic2, gameState2);
        log.info("✅ Sent to topic1: {}", topic1);
        log.info("✅ Sent to topic2: {}", topic2);
    }

}
