package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.effects.passive.CreaturePA2K;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.getCreaturePowerAttackerEffect;
import static com.duel.masters.game.effects.summoning.registry.CreatureImmediateEffectRegistry.getPowerAttackerAbility;
import static com.duel.masters.game.util.CardsDtoUtil.*;
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
                       String targetId,
                       GameWebSocketHandler websocketHandler) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var blockerFlagsDto = currentState.getBlockerFlagsDto();

        if (battleZoneHasAtLeastOneBlocker(opponentBattleZone) &&
                !blockerFlagsDto.isBlockerDecisionMade() && (
                !attackerCard.getAbility().equalsIgnoreCase("This creature cant be blocked") &&
                        !(ownCards.getBattleZone().size() > 2 && attackerCard.getAbility().contains("This creature cant be blocked while you have at least 2 other creatures in the battle zone"))
        )) {

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
                    currentState,
                    websocketHandler
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
                               GameStateDto currentState,
                               GameWebSocketHandler webSocketHandler) {

        var attackerPower = attackerCard.getPower();
        var targetPower = targetCard.getPower();
        Effect effect;

        if (getPowerAttackerAbility().contains(attackerCard.getAbility())) {
            effect = getCreaturePowerAttackerEffect(attackerCard.getAbility());
            if (effect instanceof CreaturePA2K) {
                attackerPower = attackerPower + 2000;
            } else {
                attackerPower = attackerPower + 4000;
            }
        }

        if (attackerPower > targetPower) {

            targetCard.setDestroyed(true);

            Executors
                    .newSingleThreadScheduledExecutor()
                    .schedule(
                            () -> {
                                playCard(opponentBattleZone, targetCard.getGameCardId(), opponentGraveyard);
                                currentState.getLastCardsMovedInGraveyard().add(targetCard);
                                changeCardState(attackerCard, true, false, true, false);
                                changeCardState(targetCard, false, false, false, false);
                                log.info("{} won", attackerCard.getName());
                                targetCard.setDestroyed(false);

                                playCardByAbility(currentState.getLastCardsMovedInGraveyard(), currentState);
                                topicService.sendGameStatesToTopics(currentState, webSocketHandler);
                            }
                            , 2000, TimeUnit.MILLISECONDS);

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
                                currentState.getLastCardsMovedInGraveyard().add(targetCard);
                                currentState.getLastCardsMovedInGraveyard().add(attackerCard);
                                changeCardState(attackerCard, false, false, false, false);
                                changeCardState(targetCard, false, false, false, false);
                                targetCard.setDestroyed(false);
                                attackerCard.setDestroyed(false);
                                log.info("Both lost");

                                playCardByAbility(currentState.getLastCardsMovedInGraveyard(), currentState);
                                topicService.sendGameStatesToTopics(currentState, webSocketHandler);
                            },
                            2000, TimeUnit.MILLISECONDS
                    );

        }

        if (attackerPower < targetPower) {
            attackerCard.setDestroyed(true);

            Executors
                    .newSingleThreadScheduledExecutor()
                    .schedule(() -> {
                                playCard(ownBattleZone, attackerCard.getGameCardId(), ownGraveyard);
                                currentState.getLastCardsMovedInGraveyard().add(attackerCard);
                                changeCardState(attackerCard, false, false, false, false);
                                changeCardState(targetCard, true, false, true, false);
                                log.info("{} lost", attackerCard.getName());
                                attackerCard.setDestroyed(false);

                                playCardByAbility(currentState.getLastCardsMovedInGraveyard(), currentState);
                                topicService.sendGameStatesToTopics(currentState, webSocketHandler);
                            },
                            2000, TimeUnit.MILLISECONDS);

        }
        currentState.getBlockerFlagsDto().setBlockerDecisionMade(false);
    }

    @Override
    public void attack(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
    }

}
