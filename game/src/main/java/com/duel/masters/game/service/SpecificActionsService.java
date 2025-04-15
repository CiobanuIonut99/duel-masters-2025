package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.*;
import static com.duel.masters.game.util.ValidatorUtil.canSummon;
import static com.duel.masters.game.util.ValidatorUtil.isSummonable;

@Service
@AllArgsConstructor
@Slf4j
public class SpecificActionsService {

    private final CardsUpdateService cardsUpdateService;
    private final TopicService topicService;

    public void drawCard(List<CardDto> deck, List<CardDto> hand) {
        var card = deck.getFirst();
        hand.add(card);
        deck.remove(card);
        log.info("Opponent draws card");
    }

    public void setCardsSummonable(List<CardDto> manaZone, List<CardDto> hand) {
        if (!manaZone.isEmpty()) {
            for (CardDto cardDto : hand) {
                cardDto.setSummonable(isSummonable(manaZone, cardDto));
            }
        }
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();

        var triggeredCardIds = incomingState.getTriggeredGameCardIds();
        var cardToBeSummoned = getCardDtoFromList(hand, incomingState.getTriggeredGameCardId());

        if (canSummon(getSelectedCardIds(manaZone), triggeredCardIds, manaZone, cardToBeSummoned)) {
            tapCards(getSelectedManaCards(manaZone, triggeredCardIds));
            playCard(hand, cardToBeSummoned.getGameCardId(), battleZone);
            cardToBeSummoned.setSummoningSickness(true);
            setCardsSummonable(manaZone, hand);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

    public void prepareTurnForOpponent(GameStateDto currentState, GameStateDto incomingState) {
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var opponentDeck = opponentCards.getDeck();
        var opponentHand = opponentCards.getHand();
        var opponentManaZone = opponentCards.getManaZone();
        var opponentBattleZone = opponentCards.getBattleZone();

        currentState.setCurrentTurnPlayerId(incomingState.getOpponentId());
        drawCard(opponentDeck, opponentHand);
        currentState.setPlayedMana(false);
        untapCards(opponentManaZone);
        untapCards(opponentBattleZone);
        setCardsSummonable(opponentManaZone, opponentHand);
        setCreaturesCanAttack(opponentBattleZone);
        setCreaturesAttackable(cardsUpdateService.getOwnCards(currentState, incomingState).getBattleZone());
    }

    public void setCardToSendInManaZone(GameStateDto currentState, GameStateDto incomingState) {
        if (!currentState.isPlayedMana()) {
            var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
            playCard(ownCards.getHand(), incomingState.getTriggeredGameCardId(), ownCards.getManaZone());
            setCardsSummonable(ownCards.getManaZone(), ownCards.getHand());
            currentState.setPlayedMana(true);
        } else {
            throw new AlreadyPlayedManaException();
        }
    }

    public void playCard(List<CardDto> source, String triggeredGameCardId, List<CardDto> destination) {
        source
                .stream()
                .filter(cardDto -> cardDto.getGameCardId().equals(triggeredGameCardId))
                .findFirst()
                .ifPresent(cardDto -> {
                    destination.add(cardDto);
                    source.remove(cardDto);
                });
    }

    public void doAttack(GameStateDto currentState, GameStateDto incomingState) {
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
                playCard(opponentShields, targetId, opponentHand);
            }
            var attackerPower = attackerCard.getPower();
            var targetPower = targetCard.getPower();

            if (targetCard.isTapped()) {
                if (attackerPower > targetPower) {
                    playCard(opponentBattleZone, targetId, opponentGraveyard);
                    attackerCard.setTapped(true);
                    attackerCard.setCanAttack(false);
                    attackerCard.setCanBeAttacked(true);
                }
                if (attackerPower == targetPower) {
                    playCard(opponentBattleZone, targetId, opponentGraveyard);
                    playCard(ownBattleZone, attackerId, ownGraveyard);
                    attackerCard.setCanBeAttacked(false);
                    targetCard.setCanBeAttacked(false);

                }
                if (attackerPower < targetPower) {
                    playCard(ownBattleZone, attackerId, ownGraveyard);
                    attackerCard.setCanBeAttacked(false);
                }

            }
            topicService.sendGameStatesToTopics(currentState);
        }
    }
}
