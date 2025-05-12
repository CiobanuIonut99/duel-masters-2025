package com.duel.masters.game.effects.summoning;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.List;

import static com.duel.masters.game.constant.Constant.BLOCKER;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class ScarletSkyterrorEffect implements Effect {
    //    When you put this creature into the battle zone, destroys all creature that have "blocker"
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);

        processBlockers(ownCards.getBattleZone(), ownCards.getGraveyard());
        processBlockers(opponentCards.getBattleZone(), opponentCards.getGraveyard());

    }

    private void processBlockers(List<CardDto> battlezone, List<CardDto> graveyard) {
        battlezone
                .stream()
                .filter(card -> BLOCKER.equalsIgnoreCase(card.getSpecialAbility()))
                .forEach(card -> playCard(battlezone, card.getGameCardId(), graveyard));
    }
}
