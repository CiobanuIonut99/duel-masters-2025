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

        var incomingStateShieldTriggersFlagsDto = incomingState.getShieldTriggersFlagsDto();
        var currentStateShieldTriggerFlagsDto = currentState.getShieldTriggersFlagsDto();

        if (currentStateShieldTriggerFlagsDto.isAquaSniperMustSelectCreature()) {

            List<String> chosenCardIdsFromFe = new ArrayList<>();
            if (incomingStateShieldTriggersFlagsDto.getCardsChosen() != null &&
                    !incomingStateShieldTriggersFlagsDto.getCardsChosen().isEmpty()) {
                chosenCardIdsFromFe = incomingStateShieldTriggersFlagsDto.getCardsChosen();
            }

            for (var cardId : chosenCardIdsFromFe) {

                var chosenCard = getChosenCard(cardId, ownBattleZone);
                actIfChosenCardNotNull(chosenCard, ownBattleZone, ownCards);
                chosenCard = null;
                chosenCard = getChosenCard(cardId, opponentBattleZone);
                actIfChosenCardNotNull(chosenCard, opponentBattleZone, opponentCards);
            }

            currentStateShieldTriggerFlagsDto.setAquaSniperMustSelectCreature(false);

        } else {
            if (ownBattleZone.isEmpty() && opponentBattleZone.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());
            } else {

                var eachPlayerBattleZone = currentStateShieldTriggerFlagsDto.getEachPlayerBattleZone();
                eachPlayerBattleZone.put(currentState.getPlayerId().toString(), ownBattleZone);
                eachPlayerBattleZone.put(currentState.getOpponentId().toString(), opponentBattleZone);

                currentStateShieldTriggerFlagsDto.setAquaSniperMustSelectCreature(true);
            }
        }

    }

    private static void actIfChosenCardNotNull(CardDto chosenCard, List<CardDto> ownBattleZone, CardsDto ownCards) {
        if (chosenCard != null) {
            playCard(ownBattleZone, chosenCard.getGameCardId(), ownCards.getHand());
            changeCardState(chosenCard, false, false, false, false);
        }
    }
}
