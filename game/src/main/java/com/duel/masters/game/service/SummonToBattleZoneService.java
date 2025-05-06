package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.*;
import static com.duel.masters.game.util.ValidatorUtil.canSummon;

@Slf4j
@Service
@AllArgsConstructor
public class SummonToBattleZoneService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();

        var triggeredCardIds = incomingState.getTriggeredGameCardIds();
        var cardToBeSummoned = getCardDtoFromList(hand, incomingState.getTriggeredGameCardId());
        var selectedManaCards = getSelectedManaCards(manaZone, triggeredCardIds);
        var canCardBeSummoned = canSummon(getCardIds(manaZone),
                triggeredCardIds,
                manaZone,
                selectedManaCards,
                cardToBeSummoned);

        if (canCardBeSummoned) {
            tapCards(selectedManaCards);
            playCard(hand, cardToBeSummoned.getGameCardId(), battleZone);
            log.info("Summoning {}", cardToBeSummoned.getName());
            cardToBeSummoned.setSummoningSickness(true);
            setCardsSummonable(manaZone, hand);
            topicService.sendGameStatesToTopics(currentState, webSocketHandler);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

}
