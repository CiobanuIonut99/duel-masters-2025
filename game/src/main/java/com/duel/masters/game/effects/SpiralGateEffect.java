package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.concurrent.atomic.AtomicBoolean;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class SpiralGateEffect implements ShieldTriggerEffect {

//    Choose 1 creature in the battle zone and return it to its owners hand
// NEED TEST!

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownBattleZone = ownCards.getBattleZone();
        var ownHand = ownCards.getHand();

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentHand = opponentCards.getHand();

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();
        var newTriggerGameCardId = incomingState.getTriggeredGameCardId();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {

            AtomicBoolean foundCard = new AtomicBoolean(false);

            ownBattleZone
                    .stream()
                    .filter(ownCard -> ownCard.getGameCardId().equalsIgnoreCase(newTriggerGameCardId))
                    .forEach(ownCard -> {
                        playCard(ownBattleZone, ownCard.getGameCardId(), ownHand);
                        foundCard.set(true);
                    });

            if (!foundCard.get()) {
                opponentBattleZone
                        .stream()
                        .filter(opponentCard -> opponentCard.getGameCardId().equalsIgnoreCase(newTriggerGameCardId))
                        .forEach(opponentCard -> playCard(opponentBattleZone, opponentCard.getGameCardId(), opponentHand));
            }

            changeCardState(attackerCard, true, false, true, false);

        } else {
            if (ownBattleZone.isEmpty() && opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
                shieldTriggersFlags.setSpiralGateMustSelectCreature(false);
            } else {
                var eachPlayerBattleZone = shieldTriggersFlags.getEachPlayerBattleZone();
                eachPlayerBattleZone.put(currentState.getPlayerId().toString(), ownBattleZone);
                eachPlayerBattleZone.put(currentState.getOpponentId().toString(), opponentBattleZone);

                shieldTriggersFlags.setSpiralGateMustSelectCreature(true);
            }
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
