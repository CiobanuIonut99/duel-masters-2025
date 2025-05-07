package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.getCreatureEffect;
import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.getCreatureEffectNames;
import static com.duel.masters.game.service.CardsUpdateService.isPlayer;
import static com.duel.masters.game.util.CardsDtoUtil.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoOpponentSummonBattleZone;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDtoPlayerSummonBattleZone;
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
//        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();

        var triggeredCardIds = incomingState.getTriggeredGameCardIds();
        var cardToBeSummoned = getCardDtoFromList(hand, incomingState.getTriggeredGameCardId());
        var selectedManaCards = getSelectedManaCards(manaZone, triggeredCardIds);
        var canCardBeSummoned = canSummon(getCardIds(manaZone),
                triggeredCardIds,
                manaZone,
                selectedManaCards,
                cardToBeSummoned);

        var creatureEffectNames = getCreatureEffectNames();

        if (canCardBeSummoned) {
            tapCards(selectedManaCards);
            if (ownCards.getBattleZone() == null) {
                ownCards.setBattleZone(new ArrayList<>());
            }
            playCard(hand, cardToBeSummoned.getGameCardId(), ownCards.getBattleZone());
            if (isPlayer(currentState, incomingState)) {
                currentState.setPlayerBattleZone(ownCards.getBattleZone());
            } else {
                currentState.setOpponentBattleZone(ownCards.getBattleZone());
            }

            if (creatureEffectNames.contains(cardToBeSummoned.getName())) {
                var creatureImmediateEffect = getCreatureEffect(cardToBeSummoned.getName());
                creatureImmediateEffect.execute(currentState, incomingState, cardsUpdateService);
            }
            log.info("Summoning {}", cardToBeSummoned.getName());
            cardToBeSummoned.setSummoningSickness(true);
            setCardsSummonable(manaZone, hand);


            var gameStatePlayer = getGameStateDtoPlayerSummonBattleZone(currentState);
            var gameStateOpponent = getGameStateDtoOpponentSummonBattleZone(currentState);

            topicService.sendGameStatesToTopics(currentState, webSocketHandler, gameStatePlayer, gameStateOpponent);

            log.info("Card summoned to battle zone : {}", cardToBeSummoned.getName());

        }
    }
}
