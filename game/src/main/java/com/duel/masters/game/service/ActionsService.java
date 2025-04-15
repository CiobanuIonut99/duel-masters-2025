package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;
    private final SpecificActionsService specificActionsService;

    public void endTurn(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.prepareTurnForOpponent(currentState, incomingState);
        topicService.sendGameStatesToTopics(currentState);
    }

    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.setCardToSendInManaZone(currentState, incomingState);
        topicService.sendGameStatesToTopics(currentState);
        log.info("Mana card played");
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.setCardSummonable(currentState, incomingState);
    }

    public void attack(GameStateDto currentState, GameStateDto incomingState) {

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var ownBattleZone = ownCards.getBattleZone();
        var ownGraveyard = ownCards.getGraveyard();

        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var opponentShields = opponentCards.getShields();
        var opponentHand = opponentCards.getHand();
        var opponentBattleZone = opponentCards.getBattleZone();
        var opponentGraveyard = opponentCards.getGraveyard();

        var targetId = incomingState.getTargetId();
        var attackerId = incomingState.getAttackerId();

        var attackerCard = getCardDtoFromList(ownBattleZone, attackerId);
        var targetCard = incomingState.isTargetShield() ? getCardDtoFromList(opponentShields, targetId) : getCardDtoFromList(opponentBattleZone, targetId);

        if (attackerCard.isCanAttack()) {
            if (targetCard.isShield()) {
                attackerCard.setTapped(true);
                attackerCard.setCanAttack(false);
                targetCard.setCanBeAttacked(false);
                specificActionsService.playCard(opponentShields, targetId, opponentHand);
            }
            var attackerPower = attackerCard.getPower();
            var targetPower = targetCard.getPower();

            if (targetCard.isTapped()) {
                if (attackerPower > targetPower) {
                    specificActionsService.playCard(opponentBattleZone, targetId, opponentGraveyard);
                    attackerCard.setTapped(true);
                    attackerCard.setCanAttack(false);
                    attackerCard.setCanBeAttacked(true);
                }
                if (attackerPower == targetPower) {
                    specificActionsService.playCard(opponentBattleZone, targetId, opponentGraveyard);
                    specificActionsService.playCard(ownBattleZone, attackerId, ownGraveyard);
                    attackerCard.setCanBeAttacked(false);
                    targetCard.setCanBeAttacked(false);

                }
                if (attackerPower < targetPower) {
                    specificActionsService.playCard(ownBattleZone, attackerId, ownGraveyard);
                    attackerCard.setCanBeAttacked(false);
                }

            }
            topicService.sendGameStatesToTopics(currentState);
        }
    }
}
