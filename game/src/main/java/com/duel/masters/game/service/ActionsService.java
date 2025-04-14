package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.ValidatorUtil.canAttack;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;
    private final SpecificActionsService specificActionsService;


    public void endTurn(GameStateDto currentState, GameStateDto incomingState) {

        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);

        specificActionsService.prepareTurnForOpponent(currentState, incomingState);
        specificActionsService.drawCard(opponentCards);
        specificActionsService.untapCards(opponentCards.getManaZone());
        specificActionsService.untapCards(opponentCards.getBattleZone());
        specificActionsService.setCreaturesSummonable(opponentCards);

        topicService.sendGameStatesToTopics(currentState);
    }


    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingState) {

        if (currentState.isPlayedMana()) {
            throw new AlreadyPlayedManaException();
        }

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        playCard(ownCards.getHand(), incomingState.getTriggeredGameCardId(), ownCards.getManaZone());
        currentState.setPlayedMana(true);
        specificActionsService.setCreaturesSummonable(ownCards);
        topicService.sendGameStatesToTopics(currentState);
        log.info("Mana card played");
    }

    public void playCard(List<CardDto> source, String triggeredGameCardId, List<CardDto> destination) {
        source.stream().filter(cardDto -> cardDto.getGameCardId().equals(triggeredGameCardId)).findFirst().ifPresent(cardDto -> {
            destination.add(cardDto);
            source.remove(cardDto);
        });
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();
        var selectedManaCardIds = incomingState.getTriggeredGameCardIds();
        var cardToBeSummoned = getCardDtoFromList(hand, incomingState.getTriggeredGameCardId());

        var manaZoneGameCardIds = manaZone.stream().map(CardDto::getGameCardId).toList();


        List<CardDto> selectedManaCards = new ArrayList<>();
        var isValidForSummoning = isValidForSummoning(manaZone, selectedManaCardIds, selectedManaCards, cardToBeSummoned);


        if (new HashSet<>(manaZoneGameCardIds).containsAll(incomingState.getTriggeredGameCardIds()) && manaZone.size() >= selectedManaCardIds.size() && selectedManaCardIds.size() == cardToBeSummoned.getManaCost() && isValidForSummoning) {
            for (CardDto cardDto : selectedManaCards) {
                cardDto.setTapped(true);
            }
            battleZone.add(cardToBeSummoned);
            cardToBeSummoned.setSummoningSickness(true);
            hand.remove(cardToBeSummoned);
            specificActionsService.setCreaturesSummonable(ownCards);
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


        return atLeastOneSelectedManaCardHasNecessaryCivilization && countUntapped == cardToBeSummoned.getManaCost();


    }

    public void attack(GameStateDto currentState, GameStateDto incomingState) {

        var ownBattleZone = cardsUpdateService.getOwnCards(currentState, incomingState).getBattleZone();
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentShields = opponentCards.getShields();

        var attackerCard = getCardDtoFromList(ownBattleZone, incomingState.getAttackerId());
//        var atLeastOneBlockerIntoBattleZone = opponentBattleZone
//                .stream()
//                .anyMatch(cardDto -> cardDto.getSpecialAbility().equalsIgnoreCase("BLOCKER")
//                        && !cardDto.isTapped());

        if (canAttack(attackerCard)) {
            specificActionsService.setOpponentAttackableCards(opponentBattleZone, opponentShields);
        }
    }
}
