package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.triggers.ShieldTriggerRegistry;
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
    private final AttackShieldService attackShieldService;

    public void triggerShieldTriggerLogic(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {

        if (incomingState.isUsingShieldTrigger()) {
            useShieldTrigger(currentState, incomingState);
        } else {
            doNotUseShieldTrigger(currentState, incomingState);
        }
        currentState.getShieldTriggersFlagsDto().setShieldTrigger(false);
        topicService.sendGameStatesToTopics(currentState, webSocketHandler);
    }

    private void useShieldTrigger(GameStateDto currentState, GameStateDto incomingState) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var triggeredShieldId = currentState.getTargetId();
        var trigerredShield = new CardDto();

        if (incomingState.getTriggeredGameCardId() == null &&
                incomingState.getShieldTriggersFlagsDto().getCardsChosen().isEmpty()) {
            trigerredShield = getCardDtoFromList(ownCards.getShields(), triggeredShieldId);
        } else {
            trigerredShield = currentState.getShieldTriggerCard();
        }

        var shieldTriggerEffect = ShieldTriggerRegistry
                .getShieldTriggerEffect(trigerredShield.getName());

        shieldTriggerEffect.execute(currentState, incomingState, cardsUpdateService);
    }

    private void doNotUseShieldTrigger(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var targetCard = getCardDtoFromList(ownCards.getShields(), currentState.getTargetId());
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), currentState.getAttackerId());

        attackShieldService
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
