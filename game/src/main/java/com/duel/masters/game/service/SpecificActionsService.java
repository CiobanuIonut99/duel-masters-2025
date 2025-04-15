package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.getCardDtoFromList;
import static com.duel.masters.game.util.ValidatorUtil.isSummonable;
import static com.duel.masters.game.util.ValidatorUtil.isValidForSummoning;

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

    public void untapCards(List<CardDto> cards) {
        cards.forEach(card -> card.setTapped(false));
    }

    public void setCardsSummonable(List<CardDto> manaZone, List<CardDto> hand) {
        if (!manaZone.isEmpty()) {
            for (CardDto cardDto : hand) {
                cardDto.setSummonable(isSummonable(manaZone, cardDto));
            }
        }
    }
    public void setCardSummonable(GameStateDto currentState, GameStateDto incomingState) {
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var hand = ownCards.getHand();
        var battleZone = ownCards.getBattleZone();
        var manaZone = ownCards.getManaZone();

        var selectedManaCardIds = incomingState.getTriggeredGameCardIds();
        var cardToBeSummoned = getCardDtoFromList(hand, incomingState.getTriggeredGameCardId());

        var manaZoneGameCardIds = manaZone.stream().map(CardDto::getGameCardId).toList();
        List<CardDto> selectedManaCards = new ArrayList<>();
        var isValidForSummoning = isValidForSummoning(manaZone, selectedManaCardIds, selectedManaCards, cardToBeSummoned);

        if (new HashSet<>(manaZoneGameCardIds).containsAll(incomingState.getTriggeredGameCardIds()) &&
                manaZone.size() >= selectedManaCardIds.size() &&
                selectedManaCardIds.size() == cardToBeSummoned.getManaCost() &&
                isValidForSummoning) {
            for (CardDto cardDto : selectedManaCards) {
                cardDto.setTapped(true);
            }
            battleZone.add(cardToBeSummoned);
            cardToBeSummoned.setSummoningSickness(true);
            hand.remove(cardToBeSummoned);
            setCardsSummonable(manaZone, hand);
            topicService.sendGameStatesToTopics(currentState);
            log.info("Card summoned to battle zone : {}", battleZone);
        }
    }

    public void setCreaturesAttackable(List<CardDto> cards) {
        cards.stream().filter(CardDto::isTapped).forEach(cardDto -> cardDto.setCanBeAttacked(true));
    }

    public void setCreaturesCanAttack(List<CardDto> cards) {
        cards.forEach(cardDto -> cardDto.setCanAttack(true));
    }

    public void prepareTurnForOpponent(GameStateDto currentState, GameStateDto incomingState) {
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var opponentDeck = cardsUpdateService.getOpponentCards(currentState, incomingState).getDeck();
        var opponentHand = cardsUpdateService.getOpponentCards(currentState, incomingState).getHand();
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
}
