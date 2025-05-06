package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class SpiralGateEffect implements Effect {

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
            var chosenCard = new CardDto();
            chosenCard = ownBattleZone
                    .stream()
                    .filter(ownCard -> ownCard.getGameCardId().equalsIgnoreCase(newTriggerGameCardId))
                    .findFirst()
                    .orElse(null);

            if (chosenCard != null) {
                playCard(ownBattleZone, chosenCard.getGameCardId(), ownHand);
            } else {
                chosenCard = opponentBattleZone
                        .stream()
                        .filter(opponentCard -> opponentCard.getGameCardId().equalsIgnoreCase(newTriggerGameCardId))
                        .findFirst()
                        .orElseThrow();
                playCard(opponentBattleZone, chosenCard.getGameCardId(), opponentHand);

            }
            chosenCard.setTapped(false);
            changeCardState(attackerCard, true, false, true, false);
            if (attackerCard.equals(chosenCard)) {
                attackerCard.setTapped(false);
            }
            shieldTriggersFlags.setSpiralGateMustSelectCreature(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);
        } else {
            if (ownBattleZone.isEmpty() && opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
                changeCardState(attackerCard, true, false, true, false);
            } else {
                var eachPlayerBattleZone = shieldTriggersFlags.getEachPlayerBattleZone();
                eachPlayerBattleZone.put(currentState.getPlayerId().toString(), ownBattleZone);
                eachPlayerBattleZone.put(currentState.getOpponentId().toString(), opponentBattleZone);

                shieldTriggersFlags.setSpiralGateMustSelectCreature(true);
                shieldTriggersFlags.setShieldTriggerDecisionMade(true);
                shieldTriggersFlags.setShieldTrigger(false);
            }
        }
    }
}
