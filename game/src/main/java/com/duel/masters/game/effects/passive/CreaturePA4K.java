package com.duel.masters.game.effects.passive;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

public class CreaturePA4K implements Effect {

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var attackerId = incomingState.getAttackerId();
        var attackerCard = getCardDtoFromList(ownCards.getBattleZone(), attackerId);

        attackerCard.setPower(attackerCard.getPower() + 4000);
    }
}
