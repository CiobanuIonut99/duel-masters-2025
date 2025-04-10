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

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;

    public void endTurn(GameStateDto currentState,
                        GameStateDto incomingDto) {
        log.info("Ending turn");
//        aici probabil trebuie facut din backend, nu luat opponent ID din front end
        currentState.setCurrentTurnPlayerId(incomingDto.getOpponentId());
        currentState.setPlayedMana(false);
        drawCard(currentState, incomingDto);

        topicService.sendGameStatesToTopics(currentState);
    }

    private void drawCard(GameStateDto currentState, GameStateDto incomingDto) {

        final var cardsUpdateDto = cardsUpdateService.getOpponentCards(currentState, incomingDto);

        var opponentHand = cardsUpdateDto.getHand();
        var opponentDeck = cardsUpdateDto.getDeck();
        var opponentCard = opponentDeck.getFirst();
        opponentHand.add(opponentCard);
        opponentDeck.remove(opponentCard);
        log.info("Opponent draws card");
    }

    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingDto) {

        final var cardsUpdateDto = cardsUpdateService.getOwnCards(currentState, incomingDto);

        if (!currentState.isPlayedMana()) {
            playMana(cardsUpdateDto.getHand(), incomingDto.getTriggeredGameCardId(), cardsUpdateDto.getManaZone());
            currentState.setPlayedMana(true);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Mana card played");
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
