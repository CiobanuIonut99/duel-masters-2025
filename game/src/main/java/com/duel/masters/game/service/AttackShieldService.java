package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.BlockerFlagsDto;
import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.duel.masters.game.constant.Constant.SHIELD_TRIGGER;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;
import static com.duel.masters.game.util.ValidatorUtil.battleZoneHasAtLeastOneBlocker;

@Slf4j
@Service
@AllArgsConstructor
public class AttackShieldService implements AttackService {

    private final CardsUpdateService cardsUpdateService;

    @Override
    public void attack(GameStateDto currentState,
                       GameStateDto incomingState,
                       CardDto attackerCard,
                       CardDto targetCard,
                       String targetId,
                       GameWebSocketHandler webSocketHandler) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var opponentShields = opponentCards.getShields();
        var opponentHand = opponentCards.getHand();
        var opponentBattleZone = opponentCards.getBattleZone();

        var blockerFlagsDto = currentState.getBlockerFlagsDto();

        if (battleZoneHasAtLeastOneBlocker(opponentBattleZone) &&
                !blockerFlagsDto.isBlockerDecisionMade()) {

            currentState.setOpponentHasBlocker(true);
            blockerFlagsDto.setBlockerDecisionMade(true);

        } else {


            if (SHIELD_TRIGGER.equalsIgnoreCase(targetCard.getSpecialAbility())) {
                if (blockerFlagsDto.isBlockerDecisionMade()) {
                    currentState.setShieldTriggerCard(targetCard);
                } else {
                    currentState.setShieldTriggerCard(targetCard);
                }

                currentState.getShieldTriggersFlagsDto().setShieldTrigger(true);
                currentState.setOpponentHasBlocker(false);

            } else {
                attackShieldAsPlayerOrOpponent(currentState,
                        attackerCard,
                        targetCard,
                        targetId,
                        blockerFlagsDto,
                        ownCards,
                        opponentShields,
                        opponentHand);

                currentState.getShieldTriggersFlagsDto().setShieldTrigger(false);
            }

            currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
        }
    }

    private void attackShieldAsPlayerOrOpponent(GameStateDto currentState, CardDto attackerCard, CardDto targetCard, String targetId, BlockerFlagsDto blockerFlagsDto, CardsDto ownCards, List<CardDto> opponentShields, List<CardDto> opponentHand) {
//        Daca ai selectat ca nu vrei sa blochezi cu blocker
//        se executa primul IF dpdv oponent
//        altfel se executa else dpdv player
        if (blockerFlagsDto.isBlockerDecisionMade()) {
            attackShield(
                    currentState,
                    ownCards.getShields(),
                    attackerCard.getGameCardId(),
                    ownCards.getHand(),
                    attackerCard,
                    targetCard
            );
        } else {
            attackShield(
                    currentState,
                    opponentShields,
                    targetId,
                    opponentHand,
                    targetCard,
                    attackerCard);
        }
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

        targetCard.setShield(false);
        targetCard.setCanBeAttacked(false);

        currentState.setOpponentHasBlocker(false);
    }


    @Override
    public void attack(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
    }

}
