package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class TornadoFlameEffect implements ShieldTriggerEffect {

//    Destroy 1 of your opponent.s creatures that has power 4000 or less

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
            var selectedCard = getCardDtoFromList(opponentCards.getBattleZone(), incomingState.getTriggeredGameCardId());
            playCard(opponentBattleZone, selectedCard.getGameCardId(), opponentGraveyard);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

            shieldTriggersFlags.setTornadoFlameMustSelectCreature(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

            changeCardState(attackerCard, true, false, true, false);
            if (attackerCard.getGameCardId().equals(incomingState.getTriggeredGameCardId())) {
                attackerCard.setTapped(false);
            }
        } else {
            var opponentUnder4000Creatures = shieldTriggersFlags.getOpponentUnder4000Creatures();
            opponentUnder4000Creatures.clear();
            opponentBattleZone
                    .stream()
                    .filter(opponentCard -> opponentCard.getPower() <= 4000)
                    .forEach(opponentUnder4000Creatures::add);
            if (opponentUnder4000Creatures.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
            } else {
                shieldTriggersFlags.setTornadoFlameMustSelectCreature(true);
                shieldTriggersFlags.setShieldTriggerDecisionMade(true);
                shieldTriggersFlags.setShieldTrigger(false);
            }
        }
    }
}
