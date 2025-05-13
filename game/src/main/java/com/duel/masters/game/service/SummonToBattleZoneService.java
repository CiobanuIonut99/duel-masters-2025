package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.*;
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

        var ownhand = ownCards.getHand();
        var ownManazone = ownCards.getManaZone();
        var ownBattlezone = ownCards.getBattleZone();

        var manaCardIds = incomingState.getTriggeredGameCardIds();
        var incomingStateTriggeredGameCardId = incomingState.getTriggeredGameCardId();
        CardDto cardToBeSummoned;

        if (!currentState.getEffectsDto().isHasEffect()) {

            cardToBeSummoned = getCardDtoFromList(ownhand, incomingStateTriggeredGameCardId);
            var selectedManaCards = getSelectedManaCards(ownManazone, manaCardIds);
            var canCardBeSummoned = canSummon(getCardIds(ownManazone),
                    manaCardIds,
                    ownManazone,
                    selectedManaCards,
                    cardToBeSummoned);
            if (canCardBeSummoned) {

                tapCards(selectedManaCards);
                playCard(ownhand, cardToBeSummoned.getGameCardId(), ownBattlezone);
                cardToBeSummoned.setSummoningSickness(true);
                setCardsSummonable(ownManazone, ownhand);

                var creatureEffectNames = getCreatureImmediateEffectNames();
                if (creatureEffectNames.contains(cardToBeSummoned.getName())) {
                    currentState.setTriggeredGameCardId(incomingStateTriggeredGameCardId);
                    var creatureImmediateEffect = getCreatureImmediateEffect(cardToBeSummoned.getName());
                    creatureImmediateEffect.execute(currentState, incomingState, cardsUpdateService);
                    currentState.getEffectsDto().setHasEffect(true);
                }
                if (getCreatureImmediateEffectNamesNoUi()
                        .contains(cardToBeSummoned.getName())) {
                    currentState.setTriggeredGameCardId(incomingStateTriggeredGameCardId);
                    var creatureImmediateEffectNoUi = getCreatureImmediateEffectNoUi(cardToBeSummoned.getName());
                    creatureImmediateEffectNoUi.execute(currentState, incomingState, cardsUpdateService);
                }

            }

        } else {

            cardToBeSummoned = getCardDtoFromList(ownBattlezone, currentState.getTriggeredGameCardId());
            var creatureEffectNames = getCreatureImmediateEffectNames();
            if (creatureEffectNames.contains(cardToBeSummoned.getName())) {
                var creatureImmediateEffect = getCreatureImmediateEffect(cardToBeSummoned.getName());
                creatureImmediateEffect.execute(currentState, incomingState, cardsUpdateService);
                currentState.getEffectsDto().setHasEffect(false);
            }

        }

        topicService.sendGameStatesToTopics(currentState, webSocketHandler);
        log.info("Card summoned to battle zone : {}", cardToBeSummoned.getName());
    }

}
