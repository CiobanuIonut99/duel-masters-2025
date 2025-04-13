package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsUtil.*;
import static com.duel.masters.game.util.Validator.canSummonToBattleZone;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TopicService topicService;
    private final CardsDtoService cardsDtoService;
    private final SpecificActionsService specificActionsService;

    public void endTurn(GameStateDto currentState,
                        GameStateDto incomingDto) {

        var opponentCards = cardsDtoService.getOpponentCards(currentState, incomingDto);
        specificActionsService.prepareOpponentTurn(currentState, incomingDto);
        specificActionsService.drawCard(opponentCards);
        specificActionsService.untapCards(opponentCards.getManaZone());
        specificActionsService.untapCards(opponentCards.getBattleZone());
        specificActionsService.setCreaturesSummonable(opponentCards);
        topicService.sendGameStatesToTopics(currentState);

    }


    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingDto) {

        if (currentState.isPlayedMana()) {
            throw new AlreadyPlayedManaException();
        }

        var ownCards = cardsDtoService.getOwnCards(currentState, incomingDto);
        specificActionsService.playCard(ownCards.getHand(),
                ownCards.getManaZone(),
                incomingDto.getTriggeredGameCardId());
        currentState.setPlayedMana(true);
        specificActionsService.setCreaturesSummonable(ownCards);
        topicService.sendGameStatesToTopics(currentState);
        log.info("Mana card played");
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingDto) {

        var ownCards = cardsDtoService.getOwnCards(currentState, incomingDto);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();

        var cardToBeSummoned = getCardToBeSummonedByTriggeredId(hand, incomingDto.getTriggeredGameCardId());

        var manaZoneCardsIds = getManaZoneCardsIds(manaZone);
        var manaCardsToPayForSummon = getManaCardsToPayForSummon(incomingDto.getTriggeredGameCardIds(), manaZone);

        var canCardBeSummonedToBattleZone = canSummonToBattleZone(
                cardToBeSummoned,
                manaZone,
                manaZoneCardsIds,
                manaCardsToPayForSummon,
                incomingDto
        );

        if (canCardBeSummonedToBattleZone) {
            specificActionsService.tapCards(manaCardsToPayForSummon);
            battleZone.add(cardToBeSummoned);
            hand.remove(cardToBeSummoned);
            cardToBeSummoned.setTapped(true);
            specificActionsService.setCreaturesSummonable(ownCards);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

//    public void attack(GameStateDto currentState, GameStateDto incomingDto) {
//        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingDto);
//        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingDto);
//
//        var cardToAttack = new CardDto();
//
//        var ownBattleZone = ownCards.getBattleZone();
//        var triggeredId = incomingDto.getTriggeredGameCardId();
//
//        for (CardDto cardInMyOwnBattlezone : ownBattleZone) {
//            if (cardInMyOwnBattlezone.getGameCardId().equals(triggeredId)) {
//                cardToAttack = cardInMyOwnBattlezone;
//            }
//        }
//
//
//        if (cardToAttack.getSpecialAbility().equalsIgnoreCase(DOUBLE_BREAKER)) {
//            cardToAttack.canSelectOneOpponentShield(true);
//            cardToAttack.canSelectTwoOpponentShields(true);
//
//        } else if (cardToAttack.getSpecialAbility().equalsIgnoreCase(SHIELD_BREAKER)) {
//            cardToAttack.canSelectOneOpponentShield(true);
//        } else if (cardToAttack.getSpecialAbility().equalsIgnoreCase(BLOCKER)) {
//            if (cardToAttack.getAbility().equalsIgnoreCase("")) {
//
//            }
//        }
//
//    }
}
