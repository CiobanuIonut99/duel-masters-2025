package com.duel.masters.game.effects.summoning;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.constant.Constant.ANGEL_COMMAND;

public class IocantTheOracle implements Effect {

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownBattleZone = ownCards.getBattleZone();

        var angelCommandCount = ownBattleZone
                .stream()
                .filter(ownCard -> ownCard.getRace().equals(ANGEL_COMMAND))
                .count();

        var iocantTheOracle = ownBattleZone
                .stream()
                .filter(ownCard -> ownCard.getName().equals("Iocant, the Oracle")).findFirst().get();

        var iocantInitialPower = iocantTheOracle.getPower();
        if (angelCommandCount > 0) {
            iocantTheOracle.setPower(iocantInitialPower + 2000);
        }
    }
}
