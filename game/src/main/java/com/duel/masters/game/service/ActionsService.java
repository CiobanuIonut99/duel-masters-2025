package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsUpdateDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.function.Predicate;

import static com.duel.masters.game.constant.Constant.END_TURN;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;

    public void endTurn(GameStateDto currentState,
                        GameStateDto incomingDto) {

        currentState.setCurrentTurnPlayerId(incomingDto.getOpponentId());
        currentState.setPlayedMana(false);

        drawCard(currentState, incomingDto);
        setCreaturesSummonable(cardsUpdateService.getOpponentCards(currentState, incomingDto), END_TURN);

        topicService.sendGameStatesToTopics(currentState);
    }

    private void drawCard(GameStateDto currentState, GameStateDto incomingDto) {
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingDto);
        var opponentHand = opponentCards.getHand();
        var opponentDeck = opponentCards.getDeck();
        var opponentCard = opponentDeck.getFirst();
        opponentHand.add(opponentCard);
        opponentDeck.remove(opponentCard);
        log.info("Opponent draws card");
    }

    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingDto) {

        if (currentState.isPlayedMana()) {
            throw new AlreadyPlayedManaException();
        }

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingDto);
        playCard(ownCards.getHand(), incomingDto.getTriggeredGameCardId(), ownCards.getManaZone());
        currentState.setPlayedMana(true);
        setCreaturesSummonable(cardsUpdateService.getOwnCards(currentState, incomingDto), "");
        topicService.sendGameStatesToTopics(currentState);
        log.info("Mana card played");
    }

    public void playCard(List<CardDto> source, String triggeredGameCardId, List<CardDto> destination) {
        source
                .stream()
                .filter(cardDto -> cardDto.getGameCardId().equals(triggeredGameCardId))
                .findFirst()
                .ifPresent(cardDto -> {
                    destination.add(cardDto);
                    source.remove(cardDto);
                });
    }

    public void setCreaturesSummonable(CardsUpdateDto cards, String actionType) {
        var hand = cards.getHand();
        var manaZone = cards.getManaZone();
        var battlezone = cards.getBattleZone();


        if (!manaZone.isEmpty()) {
            if (actionType.equals(END_TURN)) {
                manaZone.forEach(cardDto -> cardDto.setTapped(false));
                battlezone.forEach(cardDto -> cardDto.setTapped(false));
            }
            for (CardDto cardDto : hand) {
                var atLeastOneCardSameCivilizationPresent = manaZone
                        .stream()
                        .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()));
                var untappedManaZoneCards = manaZone
                        .stream()
                        .filter(Predicate.not(CardDto::isTapped))
                        .count();
                if (atLeastOneCardSameCivilizationPresent &&
                        manaZone.size() >= cardDto.getManaCost() &&
                        untappedManaZoneCards >= cardDto.getManaCost()
                ) {
                    cardDto.setSummonable(true);
                    log.info("Opponent summonable card : {}", cardDto.getName());
                } else {
                    cardDto.setSummonable(false);
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


        List<CardDto> selectedManaCards = new ArrayList<>();
        var isValidForSummoning = isValidForSummoning(manaZone,
                selectedManaCardIds,
                selectedManaCards,
                cardToBeSummoned);


        if (new HashSet<>(manaZoneGameCardIds)
                .containsAll(incomingDto.getTriggeredGameCardIds()) &&
                manaZone.size() >= selectedManaCardIds.size() &&
                selectedManaCardIds.size() == cardToBeSummoned.getManaCost() &&
                isValidForSummoning
        ) {
            for (CardDto cardDto : selectedManaCards) {
                cardDto.setTapped(true);
            }
            battleZone.add(cardToBeSummoned);
            hand.remove(cardToBeSummoned);
            cardToBeSummoned.setTapped(true);
            setCreaturesSummonable(ownCards, "");
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

    private boolean isValidForSummoning(List<CardDto> manaZone, List<String> selectedManaCardIds, List<CardDto> selectedManaCards, CardDto cardToBeSummoned) {
        var atLeastOneSelectedManaCardHasNecessaryCivilization = false;
        var countUntapped = 0;
        for (CardDto manaCardDto : manaZone) {
            for (String selectedManaCardId : selectedManaCardIds) {
                if (manaCardDto.getGameCardId().equals(selectedManaCardId)) {
                    selectedManaCards.add(manaCardDto);

                    if (!manaCardDto.isTapped()) {
                        countUntapped++;
                    }

                    if (manaCardDto.getCivilization().equals(cardToBeSummoned.getCivilization())) {
                        atLeastOneSelectedManaCardHasNecessaryCivilization = true;
                    }
                }
            }
        }


        return atLeastOneSelectedManaCardHasNecessaryCivilization &&
                countUntapped == cardToBeSummoned.getManaCost();


    }
}
