package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final GameStateStore gameStateStore;
    private final TopicService topicService;

    public void endTurn(GameStateDto currentState, GameStateDto incomingDto) {
        currentState.setCurrentTurnPlayerId(incomingDto.getOpponentId());
        currentState.setPlayedMana(false);
        drawCard(currentState);
        gameStateStore.saveGameState(currentState);
        topicService.sendGameStatesToTopics(currentState);
    }

    private void drawCard(GameStateDto currentState) {
        var opponentHand = currentState.getOpponentHand();
        var opponentDeck = currentState.getOpponentDeck();
        var card = opponentDeck.getFirst();
        opponentHand.add(card);
        opponentHand.remove(card);
    }

    public void sendCardToMana(GameStateDto currentState, List<CardDto> hand, GameStateDto incomingDto, List<CardDto> manaZone) {
        if (!currentState.isPlayedMana()) {
            playMana(hand,
                    incomingDto.getTriggeredGameCardId(),
                    manaZone);
            currentState.setPlayedMana(true);
            gameStateStore.saveGameState(currentState);
            topicService.sendGameStatesToTopics(currentState);
        } else {
            throw new AlreadyPlayedManaException();
        }
    }

    public void playMana(List<CardDto> hand, String triggeredGameCardId, List<CardDto> manaZone) {
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


}
