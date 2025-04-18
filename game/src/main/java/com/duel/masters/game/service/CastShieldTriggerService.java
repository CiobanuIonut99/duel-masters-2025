package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.effects.ShieldTriggerRegistry;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

@Slf4j
@Service
@AllArgsConstructor
public class CastShieldTriggerService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;
    private final AttackService attackService;

    public void triggerShieldTriggerLogic(GameStateDto currentState, GameStateDto incomingState) {

        if (incomingState.isUsingShieldTrigger()) {
            useShieldTrigger(currentState, incomingState);
        } else {
            doNotUseShieldTrigger(currentState, incomingState);
        }

        currentState.setShieldTrigger(false);
        topicService.sendGameStatesToTopics(currentState);
    }

    private void useShieldTrigger(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);

        var shieldTriggerCardId = currentState.getTargetId();
        var shieldTriggerCard = getCardDtoFromList(ownCards.getShields(), shieldTriggerCardId);

        ShieldTriggerEffect shieldTriggerEffect = ShieldTriggerRegistry.getShieldTriggerEffect(shieldTriggerCard.getName());
        shieldTriggerEffect.execute(currentState, incomingState, cardsUpdateService);

    }

    private void doNotUseShieldTrigger(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var targetCard = getCardDtoFromList(ownCards.getShields(), currentState.getTargetId());
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), currentState.getAttackerId());

        attackService
                .attackShield(
                        currentState,
                        ownCards.getShields(),
                        currentState.getTargetId(),
                        ownCards.getHand(),
                        targetCard,
                        attackerCard
                );

    }


}
