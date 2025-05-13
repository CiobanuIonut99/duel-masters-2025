package com.duel.masters.game.effects.passive;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

public class CreaturePA2K implements Effect {

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        String attackerId;
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        CardDto attackerCard;

        if (incomingState.isHasSelectedBlocker()) {
            attackerId = currentState.getAttackerId();
            attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);
        } else {
            attackerId = incomingState.getAttackerId();
            attackerCard = getCardDtoFromList(ownCards.getBattleZone(), attackerId);

        }

        attackerCard.setPower(attackerCard.getPower() + 2000);
    }
}
