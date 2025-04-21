package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class SolarRayEffect implements ShieldTriggerEffect {
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCardIdToBeTapped = incomingState.getTriggeredGameCardId();
        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (currentState.isAlreadyMadeADecision()) {

            var opponentCardToBeTapped = getCardDtoFromList(opponentCards.getBattleZone(), opponentCardIdToBeTapped);
            opponentCardToBeTapped.setTapped(true);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

            currentState.setAlreadyMadeADecision(false);
            currentState.getShieldTriggersFlagsDto().setMustSelectCreatureToTap(false);

            attackerCard.setTapped(true);
            attackerCard.setCanBeAttacked(true);
            attackerCard.setCanAttack(false);

        } else {

            var opponentSelectableCreatures = currentState.getOpponentSelectableCreatures();
            opponentSelectableCreatures.clear();
            opponentCards
                    .getBattleZone()
                    .stream()
                    .filter(cardDto -> cardDto.getType().equalsIgnoreCase("Creature")
                            &&
                            !cardDto.isTapped()
                            &&
                            !cardDto.getGameCardId().equals(attackerCard.getGameCardId())
                    )
                    .forEach(opponentSelectableCreatures::add);

            if (opponentSelectableCreatures.isEmpty()) {

                playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getHand());

                currentState.getShieldTriggersFlagsDto().setMustSelectCreatureToTap(false);
                currentState.setAlreadyMadeADecision(true);

                attackerCard.setTapped(true);
                attackerCard.setCanBeAttacked(true);
                attackerCard.setCanAttack(false);

            } else {
                currentState.getShieldTriggersFlagsDto().setMustSelectCreatureToTap(true);
                currentState.setAlreadyMadeADecision(true);
            }
        }
    }
}
