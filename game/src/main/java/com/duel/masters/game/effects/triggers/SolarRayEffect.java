package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class SolarRayEffect implements ShieldTriggerEffect {

//    Choose 1 of your opponents creatures in the battlezone and tap it

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCardIdToBeTapped = incomingState.getTriggeredGameCardId();
        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (currentState.getShieldTriggersFlagsDto().isShieldTriggerDecisionMade()) {

            var opponentCardToBeTapped = getCardDtoFromList(opponentCards.getBattleZone(), opponentCardIdToBeTapped);
            opponentCardToBeTapped.setTapped(true);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

            currentState.getShieldTriggersFlagsDto().setSolarRayMustSelectCreature(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

            changeCardState(attackerCard, true, false, true, false);
        } else {
            var opponentSelectableCreatures = currentState.getOpponentSelectableCreatures();
            opponentSelectableCreatures.clear();
            opponentCards
                    .getBattleZone()
                    .stream()
                    .filter(cardDto -> !cardDto.isTapped()
                            &&
                            !cardDto.getGameCardId().equals(attackerCard.getGameCardId()))
                    .forEach(opponentSelectableCreatures::add);
            if (opponentSelectableCreatures.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
                changeCardState(attackerCard, true, false, true, false);
            } else {
                currentState.getShieldTriggersFlagsDto().setSolarRayMustSelectCreature(true);
                currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(true);
                currentState.getShieldTriggersFlagsDto().setShieldTrigger(false);
            }
        }
    }
}
