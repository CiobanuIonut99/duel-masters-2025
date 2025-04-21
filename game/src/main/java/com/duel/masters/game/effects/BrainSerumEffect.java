package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class BrainSerumEffect implements ShieldTriggerEffect {
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (currentState.getShieldTriggersFlagsDto().isShieldTriggerDecisionMade()) {

            var cardsChosenFromDeck = incomingState
                    .getShieldTriggersFlagsDto()
                    .getCardsChosen()
                    .stream()
                    .map(idChosenFromDeck -> getCardDtoFromList(ownCards.getDeck(), idChosenFromDeck))
                    .toList();

            cardsChosenFromDeck
                    .forEach(card -> playCard(ownCards.getDeck(), card.getGameCardId(), ownCards.getHand()));

            currentState.setAlreadyMadeADecision(false);
            currentState.getShieldTriggersFlagsDto().setMustDrawCardsFromDeck(false);

            attackerCard.setTapped(true);
            attackerCard.setCanAttack(false);
            attackerCard.setCanBeAttacked(true);

        } else {

            currentState.getShieldTriggersFlagsDto().setMustDrawCardsFromDeck(true);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(true);

        }
    }
}
