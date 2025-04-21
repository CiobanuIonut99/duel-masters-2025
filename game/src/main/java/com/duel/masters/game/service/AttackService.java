package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.duel.masters.game.constant.Constant.SHIELD_TRIGGER;
import static com.duel.masters.game.util.CardsDtoUtil.*;
import static com.duel.masters.game.util.ValidatorUtil.battleZoneHasAtLeastOneBlocker;

@Slf4j
@Service
@AllArgsConstructor
public class AttackService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;

    public void attack(GameStateDto currentState, GameStateDto incomingState) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);

        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();
        var opponentShields = opponentCards.getShields();
        var opponentHand = opponentCards.getHand();
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var targetId = incomingState.getTargetId();
        var attackerId = incomingState.getAttackerId();

        var attackerCard = getCardDtoFromList(ownBattleZone, attackerId);
        var targetCard = incomingState.getShieldTriggersFlagsDto().isTargetShield() ? getCardDtoFromList(opponentShields, targetId) : getCardDtoFromList(opponentBattleZone, targetId);

        var blockerFlagsDto = currentState.getBlockerFlagsDto();

        currentState
                .getShieldTriggersFlagsDto()
                .setTargetShield(incomingState.getShieldTriggersFlagsDto().isTargetShield());
        currentState.setAttackerId(attackerId);
        currentState.setTargetId(targetId);

        if (!attackerCard.isCanAttack() || !targetCard.isCanBeAttacked()) {
            return;
        }

        if (battleZoneHasAtLeastOneBlocker(opponentBattleZone) &&
                !blockerFlagsDto.isBlockerDecisionMade()) {

            currentState.setOpponentHasBlocker(true);
            blockerFlagsDto.setBlockerDecisionMade(true);

        } else {
            if (targetCard.isShield()) {
                if (SHIELD_TRIGGER.equalsIgnoreCase(targetCard.getSpecialAbility())) {

                    currentState.getShieldTriggersFlagsDto().setShieldTrigger(true);
                    currentState.setShieldTriggerCard(targetCard);

                } else {
                    attackShield(currentState,
                            opponentShields,
                            targetId,
                            opponentHand,
                            targetCard,
                            attackerCard);
                }
            } else {
                attackCreature(
                        attackerCard,
                        targetCard,
                        opponentBattleZone,
                        opponentGraveyard,
                        ownBattleZone,
                        ownGraveyard,
                        currentState
                );
                currentState.setOpponentHasBlocker(false);
            }
        }
        topicService.sendGameStatesToTopics(currentState);
    }

    public void attackShield(GameStateDto currentState,
                             List<CardDto> opponentShields,
                             String targetId,
                             List<CardDto> opponentHand,
                             CardDto targetCard,
                             CardDto attackerCard) {

        playCard(opponentShields, targetId, opponentHand);

        attackerCard.setTapped(true);
        attackerCard.setCanAttack(false);

        targetCard.setCanBeAttacked(false);
        targetCard.setShield(false);

        currentState.setOpponentHasBlocker(false);
    }

    public void attackCreature(CardDto attackerCard,
                               CardDto targetCard,
                               List<CardDto> opponentBattleZone,
                               List<CardDto> opponentGraveyard,
                               List<CardDto> ownBattleZone,
                               List<CardDto> ownGraveyard,
                               GameStateDto currentState) {

        var attackerPower = attackerCard.getPower();
        var targetPower = targetCard.getPower();

        if (attackerPower > targetPower) {
            playCard(opponentBattleZone, targetCard.getGameCardId(), opponentGraveyard);

            changeCardState(attackerCard, true, false, true);
            changeCardState(targetCard, false, false, false);

            log.info("{} won", attackerCard.getName());
        }

        if (attackerPower == targetPower) {

            playCard(opponentBattleZone, targetCard.getGameCardId(), opponentGraveyard);
            playCard(ownBattleZone, attackerCard.getGameCardId(), ownGraveyard);

            changeCardState(attackerCard, false, false, false);
            changeCardState(targetCard, false, false, false);

            log.info("Both lost");
        }

        if (attackerPower < targetPower) {

            playCard(ownBattleZone, attackerCard.getGameCardId(), ownGraveyard);

            changeCardState(attackerCard, false, false, false);
            changeCardState(targetCard, true, false, true);

            log.info("{} lost", attackerCard.getName());
        }

        currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
    }


}
