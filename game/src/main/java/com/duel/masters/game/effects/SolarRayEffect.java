package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.Objects;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class SolarRayEffect implements ShieldTriggerEffect {
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);

        var opponentCardIdToBeTapped = incomingState.getTriggeredGameCardId();
        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (currentState.isAlreadyMadeADecision()) {

            var opponentCardToBeTapped = getCardDtoFromList(opponentCards.getBattleZone(), opponentCardIdToBeTapped);
            opponentCardToBeTapped.setTapped(true);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            currentState.setAlreadyMadeADecision(false);
            currentState.setMustSelectCreature(false);
            attackerCard.setTapped(true);
            attackerCard.setCanBeAttacked(true);
            attackerCard.setCanAttack(false);

        } else {

            if (opponentCardIdToBeTapped == null) {

                var opponentSelectableCreatures = currentState.getOpponentSelectableCreatures();
                opponentSelectableCreatures.clear();
                opponentCards
                        .getBattleZone()
                        .stream()
                        .filter(cardDto -> cardDto.getType().equalsIgnoreCase("Creature"))
                        .filter(Objects::nonNull)
                        .forEach(opponentSelectableCreatures::add);

                if (opponentSelectableCreatures.isEmpty()) {
                    playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
                    currentState.setMustSelectCreature(false);
                    currentState.setAlreadyMadeADecision(false);
                    attackerCard.setTapped(true);
                    attackerCard.setCanBeAttacked(true);
                    attackerCard.setCanAttack(false);

                } else {
                    currentState.setMustSelectCreature(true);
                    currentState.setAlreadyMadeADecision(true);
                }

            }
        }


    }
}
