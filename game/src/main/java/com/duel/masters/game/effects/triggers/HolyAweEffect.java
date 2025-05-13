package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class HolyAweEffect implements Effect {

//    Tap all your opponnents creatures in the battle zone

    @Override
    public void execute(GameStateDto currentState,
                        GameStateDto incomingState,
                        CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var opponentBattleZone = opponentCards.getBattleZone();

        tapCards(opponentBattleZone);
        setOpponentsCreaturesCanNotAttack(opponentBattleZone);
        playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
    }
}
