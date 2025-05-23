package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class NaturalSnareEffect implements Effect {

//    Choose one of your opponent.s creatures in the battle zone and put it into his mana zone

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentManaZone = opponentCards.getManaZone();

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            opponentBattleZone
                    .stream()
                    .filter(opponentCard -> opponentCard.getGameCardId().equalsIgnoreCase(incomingState.getTriggeredGameCardId()))
                    .forEach(opponentCard -> playCard(opponentBattleZone, opponentCard.getGameCardId(), opponentManaZone));
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);
            shieldTriggersFlags.setNaturalSnareMustSelectCreature(false);
            changeCardState(attackerCard, true, false, true, false);
            if (attackerCard.getGameCardId().equals(incomingState.getTriggeredGameCardId())) {
                attackerCard.setTapped(false);
            }
        } else {
            if (opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
                changeCardState(attackerCard, true, false, true, false);
            }
            shieldTriggersFlags.setNaturalSnareMustSelectCreature(true);
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
