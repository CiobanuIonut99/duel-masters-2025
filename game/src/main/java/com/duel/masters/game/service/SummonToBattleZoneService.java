package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.*;
import static com.duel.masters.game.effects.summoning.registry.CreatureRegistry.getCreatureEffect;
import static com.duel.masters.game.effects.summoning.registry.CreatureRegistry.getCreatureEffectNames;
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

        var ownHand = ownCards.getHand();
        var ownManaZone = ownCards.getManaZone();
        var ownBattleZone = ownCards.getBattleZone();

        var manaCardIds = incomingState.getTriggeredGameCardIds();
        var incomingStateTriggeredGameCardId = incomingState.getTriggeredGameCardId();
        CardDto cardToBeSummoned;

        if (!currentState.getEffectsDto().isHasEffect()) {

            cardToBeSummoned = getCardDtoFromList(ownHand, incomingStateTriggeredGameCardId);
            var selectedManaCards = getSelectedManaCards(ownManaZone, manaCardIds);
            var canCardBeSummoned = canSummon(getCardIds(ownManaZone),
                    manaCardIds,
                    ownManaZone,
                    selectedManaCards,
                    cardToBeSummoned);
            if (canCardBeSummoned) {

                tapCards(selectedManaCards);
                playCard(ownHand, cardToBeSummoned.getGameCardId(), ownBattleZone);
                cardToBeSummoned.setSummoningSickness(true);
                setCardsSummonable(ownManaZone, ownHand);

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

                if (getCreatureEffectNames().contains(cardToBeSummoned.getName())) {
                    getCreatureEffect(cardToBeSummoned.getName()).execute(currentState, incomingState, cardsUpdateService);
                }
            }
        } else {

            cardToBeSummoned = getCardDtoFromList(ownBattleZone, currentState.getTriggeredGameCardId());
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
