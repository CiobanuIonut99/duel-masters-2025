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
        var selectedManaCards = getSelectedManaCards(manaZone, triggeredCardIds);
        selectedManaCards
                .forEach(selectedManaCard -> {
                    log.info("Selected mana card : {}", selectedManaCard.getName());
                });

        if (canSummon(getCardIds(manaZone), triggeredCardIds, manaZone, selectedManaCards, cardToBeSummoned)) {
            tapCards(selectedManaCards);
            selectedManaCards
                    .forEach(selectedManaCard -> {
                        log.info("Tapped card : {}", selectedManaCard.getName());
                    });

            playCard(hand, cardToBeSummoned.getGameCardId(), battleZone);
            log.info("Summoning {}", cardToBeSummoned.getName());
            cardToBeSummoned.setSummoningSickness(true);
            setCardsSummonable(manaZone, hand);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

    public void endTurn(GameStateDto currentState, GameStateDto incomingState) {
        log.info("Current player ends turn");
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
        cureSickness(opponentBattleZone);

//        MOCK FOR SINGLE TESTING
//        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
//        var hand = ownCards.getHand();
//        var deck = ownCards.getDeck();
//        playCard(deck, deck.getFirst().getGameCardId(), hand);

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
            log.info("Attacker card : {} with power : {}", attackerCard.getName(), attackerCard.getPower());

            if (targetCard.isShield()) {
                log.info("Card is shield");
                attackerCard.setTapped(true);
                attackerCard.setCanAttack(false);
                targetCard.setCanBeAttacked(false);
                playCard(opponentShields, targetId, opponentHand);
            }
            var attackerPower = attackerCard.getPower();
            var targetPower = targetCard.getPower();

            if (targetCard.isTapped()) {
                log.info("Target card : {} with power : {} ", targetCard.getName(), targetCard.getPower());
                if (attackerPower > targetPower) {
                    playCard(opponentBattleZone, targetId, opponentGraveyard);

                    attackerCard.setTapped(true);
                    attackerCard.setCanAttack(false);
                    attackerCard.setCanBeAttacked(true);

                    targetCard.setCanBeAttacked(false);
                    targetCard.setCanAttack(false);

                    log.info("{} won", attackerCard.getName());
                }
                if (attackerPower == targetPower) {
                    playCard(opponentBattleZone, targetId, opponentGraveyard);
                    playCard(ownBattleZone, attackerId, ownGraveyard);

                    attackerCard.setCanBeAttacked(false);
                    attackerCard.setCanAttack(false);

                    targetCard.setCanBeAttacked(false);
                    targetCard.setCanAttack(false);
                    log.info("Both lost");
                }
                if (attackerPower < targetPower) {
                    playCard(ownBattleZone, attackerId, ownGraveyard);

                    attackerCard.setCanBeAttacked(false);
                    attackerCard.setCanAttack(false);

                    targetCard.setCanBeAttacked(true);
                    targetCard.setCanAttack(false);

                    log.info("{} lost", attackerCard.getName());
                }

            }
            topicService.sendGameStatesToTopics(currentState);
        }
    }


}
