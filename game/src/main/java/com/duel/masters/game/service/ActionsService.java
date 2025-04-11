package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsUpdateDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
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
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingDto);
        setCreaturesSummonable(opponentCards);
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
            playCard(ownCards.getHand(), incomingDto.getTriggeredGameCardId(), ownCards.getManaZone());
            currentState.setPlayedMana(true);
            setCreaturesSummonable(cardsUpdateService.getOwnCards(currentState, incomingDto));
            topicService.sendGameStatesToTopics(currentState);
            log.info("Mana card played");
        } else {
            throw new AlreadyPlayedManaException();
        }
    }

    public CardDto playCard(List<CardDto> source, String triggeredGameCardId, List<CardDto> destination) {
        log.info("Playing card source : {}", source);
        CardDto toMoveAndRemove = null;
        for (CardDto cardDto : source) {
            if (cardDto.getGameCardId().equals(triggeredGameCardId)) {
                toMoveAndRemove = cardDto;
                break;
            }
        }
        destination.add(toMoveAndRemove);
        source.remove(toMoveAndRemove);
        return toMoveAndRemove;
    }

    public void setCreaturesSummonable(CardsUpdateDto cards) {
        var hand = cards.getHand();
        var manaZone = cards.getManaZone();

        if (!manaZone.isEmpty()) {
            manaZone.forEach(cardDto -> cardDto.setTapped(false));
            for (CardDto cardDto : hand) {
                var atLeastOneCardSameCivilizationPresent = manaZone
                        .stream()
                        .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()));
                log.info("START LOG *************************************************************************");
                log.info("At least one card same civilization present in mana : {}", atLeastOneCardSameCivilizationPresent);
                log.info("CardDto mana needed to be summoned : {}", cardDto.getManaCost());
                log.info("CardDto name : {}", cardDto.getName());
                log.info("Opponent mana zone size : {}", manaZone.size());
                log.info("STOP LOG *************************************************************************");
                if (atLeastOneCardSameCivilizationPresent && manaZone.size() >= cardDto.getManaCost()) {
                    cardDto.setSummonable(true);
                    log.info("Opponent summonable card : {}", cardDto.getName());
                }
            }
        }
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingDto) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingDto);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();
        var selectedManaCardIds = incomingDto.getTriggeredGameCardIds();
        var cardToBeSummoned = new CardDto();

        for (CardDto cardDto : hand) {
            if (cardDto.getGameCardId().equals(incomingDto.getTriggeredGameCardId())) {
                cardToBeSummoned = cardDto;
                break;
            }
        }
        var manaZoneGameCardIds = manaZone
                .stream()
                .map(CardDto::getGameCardId)
                .toList();

        boolean atLeastOneSelectedManaHasNecessaryCivilization = false;
        List<CardDto> selectedManaCards = new ArrayList<>();
        for (int i = 0; i < manaZone.size(); i++) {
            for (int j = 0; j < selectedManaCardIds.size(); j++) {
                var selectedCard = manaZone.get(i);
                if (selectedCard.getGameCardId().equals(selectedManaCardIds.get(j))) {
                    selectedManaCards.add(selectedCard);
                    if (selectedCard.getCivilization().equals(cardToBeSummoned.getCivilization())) {
                        atLeastOneSelectedManaHasNecessaryCivilization = true;
                    }
                }
            }
        }

        if (manaZoneGameCardIds.containsAll(incomingDto.getTriggeredGameCardIds()) &&
                manaZone.size() >= selectedManaCardIds.size() &&
                selectedManaCardIds.size() == cardToBeSummoned.getManaCost() &&
                atLeastOneSelectedManaHasNecessaryCivilization
        ) {
            for (CardDto cardDto : selectedManaCards) {
                cardDto.setTapped(true);
            }
            battleZone.add(cardToBeSummoned);
            hand.remove(cardToBeSummoned);
            cardToBeSummoned.setTapped(true);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }
}
