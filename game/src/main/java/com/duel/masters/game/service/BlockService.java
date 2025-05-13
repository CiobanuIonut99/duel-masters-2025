package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

@Slf4j
@Service
@AllArgsConstructor
public class BlockService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;
    private final AttackShieldService attackShieldService;
    private final AttackCreatureService attackCreatureService;

    public void block(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);

        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();
        var ownShields = ownCards.getShields();
        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();

        if (incomingState.isHasSelectedBlocker()) {

            var attackerId = currentState.getAttackerId();
            var targetId = incomingState.getTargetId();

            var attackerCard = getCardDtoFromList(opponentBattleZone, attackerId);
            var targetCard = getCardDtoFromList(ownBattleZone, targetId);

            attackCreatureService.attackCreature(
                    attackerCard,
                    targetCard,
                    ownBattleZone,
                    ownGraveyard,
                    opponentBattleZone,
                    opponentGraveyard,
                    currentState,
                    webSocketHandler
            );

            currentState.setOpponentHasBlocker(false);
            topicService.sendGameStatesToTopics(currentState, webSocketHandler);

        } else {

            var attackerId = currentState.getAttackerId();
            var targetId = currentState.getTargetId();

            var attackerCard = getCardDtoFromList(opponentBattleZone, attackerId);
            var targetCard = currentState.getShieldTriggersFlagsDto().isTargetShield() ? getCardDtoFromList(ownShields, targetId) : getCardDtoFromList(ownBattleZone, targetId);

            if (targetCard.isShield()) {

                attackShieldService.attack(
                        currentState,
                        incomingState,
                        attackerCard,
                        targetCard,
                        attackerId,
                        webSocketHandler
                );

            } else {

                attackCreatureService.attackCreature(
                        attackerCard,
                        targetCard,
                        ownBattleZone,
                        ownGraveyard,
                        opponentBattleZone,
                        opponentGraveyard,
                        currentState,
                        webSocketHandler
                );
                currentState.setOpponentHasBlocker(false);

            }

            topicService.sendGameStatesToTopics(currentState, webSocketHandler);
        }
    }
}
