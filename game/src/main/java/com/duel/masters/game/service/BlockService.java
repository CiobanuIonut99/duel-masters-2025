package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;

@Slf4j
@Service
@AllArgsConstructor
public class BlockService {

    private final TopicService topicService;
    private final AttackService attackService;
    private final CardsUpdateService cardsUpdateService;

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

            attackService.attackCreature(
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
            var targetCard = currentState.isTargetShield() ? getCardDtoFromList(ownShields, targetId) : getCardDtoFromList(ownBattleZone, targetId);

            if (targetCard.isShield()) {
                playCard(ownShields, targetId, ownHand);
                log.info("target was shield : {}", targetCard.getName());
                attackerCard.setTapped(true);
                attackerCard.setCanAttack(false);
                targetCard.setCanBeAttacked(false);
                targetCard.setShield(false);
                currentState.setOpponentHasBlocker(false);
            } else {
                attackService.attackCreature(
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
        }
    }
}
