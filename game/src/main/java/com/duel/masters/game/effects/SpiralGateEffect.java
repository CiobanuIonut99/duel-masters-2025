package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

public class SpiralGateEffect implements ShieldTriggerEffect {

//    Choose 1 creature in the battle zone and return it to its owners hand

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownBattleZone = ownCards.getBattleZone();
        var ownHand = ownCards.getHand();

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentHand = opponentCards.getHand();

        if (currentState.getShieldTriggersFlagsDto().isShieldTriggerDecisionMade()) {

        } else {
            var eachPlayerBattleZone = currentState.getShieldTriggersFlagsDto().getEachPlayerBattleZone();
            eachPlayerBattleZone.put(currentState.getPlayerId().toString(), ownBattleZone);
            eachPlayerBattleZone.put(currentState.getOpponentId().toString(), opponentBattleZone);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(true);
        }
    }
}
