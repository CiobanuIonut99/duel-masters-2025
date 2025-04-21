package com.duel.masters.game.service;

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

    public void block(GameStateDto currentState, GameStateDto incomingState) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);

        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();
        var ownShields = ownCards.getShields();
        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();
        var ownHand = ownCards.getHand();

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
                    currentState
            );

            currentState.setOpponentHasBlocker(false);
            topicService.sendGameStatesToTopics(currentState);

        } else {

            var attackerId = currentState.getAttackerId();
            var targetId = currentState.getTargetId();

            var attackerCard = getCardDtoFromList(opponentBattleZone, attackerId);
            var targetCard = currentState.getShieldTriggersFlagsDto().isTargetShield() ? getCardDtoFromList(ownShields, targetId) : getCardDtoFromList(ownBattleZone, targetId);

            if (targetCard.isShield()) {


                if (targetCard.getSpecialAbility().equalsIgnoreCase("SHIELD_TRIGGER")) {
                    currentState.getShieldTriggersFlagsDto().setShieldTrigger(true);
                    currentState.setOpponentHasBlocker(false);
                    currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
                    currentState.setShieldTriggerCard(targetCard);
                } else {
                    attackShieldService.attackShield(
                            currentState,
                            ownShields,
                            targetId,
                            ownHand,
                            targetCard,
                            attackerCard
                    );

                    currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
                    currentState.getShieldTriggersFlagsDto().setShieldTrigger(false);
                }


            } else {
                attackCreatureService.attackCreature(
                        attackerCard,
                        targetCard,
                        ownBattleZone,
                        ownGraveyard,
                        opponentBattleZone,
                        opponentGraveyard,
                        currentState
                );
                currentState.setOpponentHasBlocker(false);

            }

            topicService.sendGameStatesToTopics(currentState);
        }
    }
}
