package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class DarkReversalEffect implements Effect {

    //    Return a creature from your graveyard to your hand
    // NEED TEST!

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownGraveyard = ownCards.getGraveyard();
        var ownHand = ownCards.getHand();

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            ownGraveyard
                    .stream()
                    .filter(ownCard -> ownCard.getGameCardId().equalsIgnoreCase(incomingState.getTriggeredGameCardId()))
                    .forEach(ownCard -> playCard(ownGraveyard, ownCard.getGameCardId(), ownHand));

            playCard(ownCards.getShields(), currentState.getTargetId(), ownGraveyard);
            changeCardState(attackerCard, true, false, true, false);
            shieldTriggersFlags.setDarkReversalMustSelectCreature(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);
        } else {
            var playerCreatureGraveyard = shieldTriggersFlags.getPlayerCreatureGraveyard();
            playerCreatureGraveyard.clear();
            ownGraveyard
                    .stream()
                    .filter(ownCard -> ownCard.getType().equalsIgnoreCase("CREATURE"))
                    .forEach(playerCreatureGraveyard::add);
            if (playerCreatureGraveyard.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
                changeCardState(attackerCard, true, false, true, false);
            } else {
                shieldTriggersFlags.setDarkReversalMustSelectCreature(true);
                shieldTriggersFlags.setShieldTriggerDecisionMade(true);
                shieldTriggersFlags.setShieldTrigger(false);
            }

        }
    }
}
