package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static com.duel.masters.game.util.CardsDtoUtil.changeCardState;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;
import static com.duel.masters.game.util.ValidatorUtil.battleZoneHasAtLeastOneBlocker;

@Slf4j
@Service
@AllArgsConstructor
public class AttackCreatureService implements AttackService {

    private final CardsUpdateService cardsUpdateService;
    private final TopicService topicService;


    @Override
    public void attack(GameStateDto currentState,
                       GameStateDto incomingState,
                       CardDto attackerCard,
                       CardDto targetCard,
                       String targetId) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var blockerFlagsDto = currentState.getBlockerFlagsDto();

        if (battleZoneHasAtLeastOneBlocker(opponentBattleZone) &&
                !blockerFlagsDto.isBlockerDecisionMade()) {

            currentState.setOpponentHasBlocker(true);
            blockerFlagsDto.setBlockerDecisionMade(true);

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
            targetCard.setDestroyed(true);

            Executors
                    .newSingleThreadScheduledExecutor()
                    .schedule(
                            () -> {
                                playCard(opponentBattleZone, targetCard.getGameCardId(), opponentGraveyard);
                                changeCardState(attackerCard, true, false, true, false);
                                changeCardState(targetCard, false, false, false, false);
                                log.info("{} won", attackerCard.getName());
                                targetCard.setDestroyed(false);
                                topicService.sendGameStatesToTopics(currentState);
                            }
                            , 700, TimeUnit.MILLISECONDS);

        }

        if (attackerPower == targetPower) {

            targetCard.setDestroyed(true);
            attackerCard.setDestroyed(true);

            Executors
                    .newSingleThreadScheduledExecutor()
                    .schedule(
                            () -> {
                                playCard(opponentBattleZone, targetCard.getGameCardId(), opponentGraveyard);
                                playCard(ownBattleZone, attackerCard.getGameCardId(), ownGraveyard);

                                changeCardState(attackerCard, false, false, false, false);
                                changeCardState(targetCard, false, false, false, false);
                                targetCard.setDestroyed(false);
                                attackerCard.setDestroyed(false);
                                log.info("Both lost");

                                topicService.sendGameStatesToTopics(currentState);
                            },
                            700, TimeUnit.MILLISECONDS
                    );

        }

        if (attackerPower < targetPower) {

            attackerCard.setDestroyed(true);

            Executors
                    .newSingleThreadScheduledExecutor()
                    .schedule(() -> {
                                playCard(ownBattleZone, attackerCard.getGameCardId(), ownGraveyard);
                                changeCardState(attackerCard, false, false, false, false);
                                changeCardState(targetCard, true, false, true, false);
                                log.info("{} lost", attackerCard.getName());
                                attackerCard.setDestroyed(false);

                                topicService.sendGameStatesToTopics(currentState);
                            },
                            700, TimeUnit.MILLISECONDS);

        }

        currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
    }

    @Override
    public void attack(GameStateDto currentState, GameStateDto incomingState) {

    }

}
