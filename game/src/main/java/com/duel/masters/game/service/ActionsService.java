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
        currentState.setCurrentTurnPlayerId(incomingDto.getOpponentId());
        currentState.setPlayedMana(false);
        drawCard(currentState, incomingDto);
        setOpponentCreaturesSummonable(currentState, incomingDto);
        log.info("****************************".repeat(20));
        log.info("GAME STATE : {}", currentState);
        log.info("****************************".repeat(20));
        topicService.sendGameStatesToTopics(currentState);
    }

    private void drawCard(GameStateDto currentState, GameStateDto incomingDto) {

        final var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingDto);

        var opponentHand = opponentCards.getHand();
        var opponentDeck = opponentCards.getDeck();
        var opponentCard = opponentDeck.getFirst();
        opponentHand.add(opponentCard);
        opponentDeck.remove(opponentCard);
        log.info("Opponent draws card");
    }

    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingDto) {

        final var ownCards = cardsUpdateService.getOwnCards(currentState, incomingDto);

        if (!currentState.isPlayedMana()) {
            playMana(ownCards.getHand(), incomingDto.getTriggeredGameCardId(), ownCards.getManaZone());
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

    public void setOpponentCreaturesSummonable(GameStateDto currentState, GameStateDto incomingDto) {
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingDto);
        var opponentHand = opponentCards.getHand();
        var opponentManaZone = opponentCards.getManaZone();

        if (!opponentManaZone.isEmpty()) {
            opponentManaZone.forEach(cardDto -> cardDto.setTapped(false));
            for (CardDto cardDto : opponentHand) {
                var atLeastOneCardSameCivilizationPresent = opponentManaZone
                        .stream()
                        .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()));
                log.info("START LOG *************************************************************************");
                log.info("At least one card same civilization present in mana : {}", atLeastOneCardSameCivilizationPresent);
                log.info("CardDto mana needed to be summoned : {}", cardDto.getManaCost());
                log.info("CardDto name : {}", cardDto.getName());
                log.info("Opponent mana zone size : {}", opponentManaZone.size());
                log.info("STOP LOG *************************************************************************");
                if (atLeastOneCardSameCivilizationPresent && opponentManaZone.size() >= cardDto.getManaCost()) {
                    cardDto.setSummonable(true);
                    log.info("Opponent summonable card : {}", cardDto.getName());
                }
            }
        }
    }
}
