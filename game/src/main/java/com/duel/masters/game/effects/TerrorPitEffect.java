package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class TerrorPitEffect implements ShieldTriggerEffect {

//    Destroy 1 of your opponent.s creatures

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            opponentBattleZone
                    .stream()
                    .filter(opponentCard -> opponentCard.getGameCardId().equalsIgnoreCase(incomingState.getTriggeredGameCardId()))
                    .forEach(opponentCard -> playCard(opponentBattleZone, opponentCard.getGameCardId(), opponentGraveyard));
        } else {
            if (opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), opponentCards.getHand());
                shieldTriggersFlags.setTerrorPitMustSelectCreature(false);
            } else {
                shieldTriggersFlags.setTerrorPitMustSelectCreature(true);
            }
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
