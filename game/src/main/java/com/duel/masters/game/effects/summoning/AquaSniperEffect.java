package com.duel.masters.game.effects.summoning;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.ArrayList;
import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.*;

// When you put this creature into the battle zone, choose up to 2 creatures in the battle zone and return them to their owners hands

public class AquaSniperEffect implements Effect {

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);

        var ownBattleZone = ownCards.getBattleZone();
        var opponentBattleZone = opponentCards.getBattleZone();

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {

            List<String> chosenCardIdsFromFe = new ArrayList<>();
            if (shieldTriggersFlags.getCardsChosen() != null &&
                    !shieldTriggersFlags.getCardsChosen().isEmpty()) {
                chosenCardIdsFromFe = shieldTriggersFlags.getCardsChosen();
            }

            for (var cardId : chosenCardIdsFromFe) {

                var chosenCard = getChosenCard(cardId, ownBattleZone);
                chosenCard = null;
                chosenCard = getChosenCard(cardId, opponentBattleZone);
                actIfChosenCardNotNull(chosenCard, ownBattleZone, ownCards);
            }

            shieldTriggersFlags.setAquaSniperMustSelectCreature(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

        } else {
            if (ownBattleZone.isEmpty() && opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
            } else {

                var eachPlayerBattleZone = shieldTriggersFlags.getEachPlayerBattleZone();
                eachPlayerBattleZone.put(currentState.getPlayerId().toString(), ownBattleZone);
                eachPlayerBattleZone.put(currentState.getOpponentId().toString(), opponentBattleZone);

                shieldTriggersFlags.setAquaSniperMustSelectCreature(true);
                shieldTriggersFlags.setShieldTriggerDecisionMade(true);
                shieldTriggersFlags.setShieldTrigger(false);
            }
        }

    }

    private static void actIfChosenCardNotNull(CardDto chosenCard, List<CardDto> ownBattleZone, CardsDto ownCards) {
        if (chosenCard != null) {
            playCard(ownBattleZone, chosenCard.getGameCardId(), ownCards.getHand());
            chosenCard.setTapped(false);
        }
    }
}
