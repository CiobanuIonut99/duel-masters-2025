package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.ShieldTriggersFlagsDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

@Slf4j
@Service
@AllArgsConstructor
public class AttackServiceImplementation implements AttackService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;
    private final AttackShieldService attackShieldService;
    private final AttackCreatureService attackCreatureService;

    @Override
    public void attack(GameStateDto currentState,
                       GameStateDto incomingState,
                       CardDto attackerCard,
                       CardDto targetCard,
                       String targetId,
                       GameWebSocketHandler webSocketHandler) {

    }

    @Override
    public void attack(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var attackerId = incomingState.getAttackerId();
        var targetId = incomingState.getTargetId();

        var attackerCard = getCardDtoFromList(ownCards.getBattleZone(), attackerId);
        var targetCard = incomingState
                .getShieldTriggersFlagsDto()
                .isTargetShield()
                ?
                getCardDtoFromList(opponentCards.getShields(), targetId)
                :
                getCardDtoFromList(opponentCards.getBattleZone(), targetId);


        if (currentState.getShieldTriggersFlagsDto() != null) {
            currentState
                    .getShieldTriggersFlagsDto()
                    .setTargetShield(incomingState.getShieldTriggersFlagsDto().isTargetShield());
        } else {
            currentState.setShieldTriggersFlagsDto(new ShieldTriggersFlagsDto());
            currentState.getShieldTriggersFlagsDto().setTargetShield(
                    incomingState.getShieldTriggersFlagsDto().isTargetShield()
            );
        }
        currentState.setAttackerId(attackerId);
        currentState.setTargetId(targetId);

        if (!attackerCard.isCanAttack() || !targetCard.isCanBeAttacked()) {
            return;
        }

        if (targetCard.isShield()) {
            attackShieldService.attack(currentState, incomingState, attackerCard, targetCard, targetId, webSocketHandler);
        } else {
            attackCreatureService.attack(currentState, incomingState, attackerCard, targetCard, targetId, webSocketHandler);
        }


        topicService.sendGameStatesToTopics(currentState, webSocketHandler);
//        var gameStatePlayer = getGameStateDtoPlayerAttack(currentState);
//        var gameStateOpponent = getGameStateDtoOpponentAttack(currentState);
//        topicService.sendGameStatesToTopics(currentState, webSocketHandler, gameStatePlayer, gameStateOpponent);

    }
}
