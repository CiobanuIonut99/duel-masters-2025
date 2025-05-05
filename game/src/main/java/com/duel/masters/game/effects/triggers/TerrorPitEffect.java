package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class TerrorPitEffect implements ShieldTriggerEffect {

//    Destroy 1 of your opponent.s creatures

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            var chosencard = new CardDto();
            chosencard = opponentBattleZone
                    .stream()
                    .filter(opponentCard -> opponentCard.getGameCardId().equalsIgnoreCase(incomingState.getTriggeredGameCardId()))
                    .findFirst()
                    .orElseThrow();
            playCard(opponentBattleZone, chosencard.getGameCardId(), opponentGraveyard);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            changeCardState(attackerCard, true, false, true, false);
            currentState.getShieldTriggersFlagsDto().setTerrorPitMustSelectCreature(false);
            chosencard.setTapped(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

        } else {
            if (opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), opponentCards.getHand());
                shieldTriggersFlags.setTerrorPitMustSelectCreature(false);
            } else {
                shieldTriggersFlags.setTerrorPitMustSelectCreature(true);
            }
            shieldTriggersFlags.setShieldTrigger(false);
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
        }
    }
}
