package com.duel.masters.game.util;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

import static com.duel.masters.game.util.ValidatorUtil.isSummonable;

@Slf4j
public class CardsDtoUtil {
    public static CardsDto getCardsDto(List<CardDto> hand,
                                       List<CardDto> manaZone,
                                       List<CardDto> deck,
                                       List<CardDto> graveyard,
                                       List<CardDto> battleZone,
                                       List<CardDto> shields) {
        return
                CardsDto
                        .builder()
                        .hand(hand)
                        .manaZone(manaZone)
                        .deck(deck)
                        .graveyard(graveyard)
                        .battleZone(battleZone)
                        .shields(shields)
                        .build();
    }

    public static Long untappedCards(List<CardDto> cards) {
        return cards
                .stream()
                .filter(cardDto1 -> !cardDto1.isTapped())
                .count();
    }

    public static CardDto getCardDtoFromList(List<CardDto> cards, String cardId) {
        if (!cards.isEmpty()) {
            return cards
                    .stream()
                    .filter(cardDto -> cardDto.getGameCardId().equals(cardId))
                    .findFirst()
                    .orElseThrow();
        } else {
            throw new RuntimeException("Card not found");
        }
    }


    public static List<CardDto> getSelectedManaCards(List<CardDto> manaZone, List<String> selectedManaCardIds) {
        var selectedManaCards = new ArrayList<CardDto>();

        if (!manaZone.isEmpty()) {
            for (CardDto manaCardDto : manaZone) {
                for (String selectedManaCardId : selectedManaCardIds) {
                    if (manaCardDto.getGameCardId().equals(selectedManaCardId)) {
                        selectedManaCards.add(manaCardDto);
                    }
                }
            }
            return selectedManaCards;
        } else {
            throw new RuntimeException("ManaZone is empty");
        }
    }


    public static List<String> getCardIds(List<CardDto> cards) {
        return cards
                .stream()
                .map(CardDto::getGameCardId)
                .toList();
    }

    public static void setOpponentsCreaturesAttackable(List<CardDto> cards) {
        if (cards == null || cards.isEmpty()) {
            return;
        }
        cards.stream().filter(CardDto::isTapped).forEach(cardDto -> cardDto.setCanBeAttacked(true));
    }

    public static void setOpponentsCreaturesCanAttack(List<CardDto> cards) {
        if (cards == null || cards.isEmpty()) {
            return;
        }
        cards.forEach(cardDto -> cardDto.setCanAttack(true));
    }

    public static void setOpponentsCreaturesCanNotAttack(List<CardDto> cards) {
        cards.forEach(cardDto -> cardDto.setCanAttack(false));
    }

    public static void untapOpponentsCards(List<CardDto> cards) {
        if (cards == null || cards.isEmpty()) {
            return;
        }
        cards.forEach(card -> card.setTapped(false));
    }

    public static void tapCards(List<CardDto> cards) {
        cards.forEach(card -> card.setTapped(true));
    }

    public static void cureOpponentsCreaturesSickness(List<CardDto> cards) {
        if (cards == null || cards.isEmpty()) {
            return;
        }
        cards
                .stream()
                .filter(CardDto::isSummoningSickness)
                .forEach(cardDto -> cardDto.setSummoningSickness(false));
    }

    public static void setCardsSummonable(List<CardDto> manaZone, List<CardDto> hand) {
        if (manaZone == null || manaZone.isEmpty()) {
            return;
        }
        if (hand == null || hand.isEmpty()) {
            return;
        }
        for (CardDto cardDto : hand) {
            cardDto.setSummonable(isSummonable(manaZone, cardDto));
        }
    }

    public static void playCard(List<CardDto> source, String triggeredGameCardId, List<CardDto> destination) {
        source
                    .stream()
                    .filter(cardDto -> cardDto.getGameCardId().equals(triggeredGameCardId))
                    .findFirst()
                    .ifPresent(cardDto -> {
                        destination.add(cardDto);
                        source.remove(cardDto);
                    });

    }

    public static void drawCard(List<CardDto> deck, List<CardDto> hand) {
        var card = deck.getFirst();
        hand.add(card);
        deck.remove(card);
    }

    public static void changeCardState(CardDto card, boolean tapped, boolean canAttack, boolean canBeAttacked, boolean summoningSickness) {
        card.setTapped(tapped);
        card.setCanAttack(canAttack);
        card.setCanBeAttacked(canBeAttacked);
        card.setSummoningSickness(false);
    }

    public static CardDto getChosenCard(String cardId, List<CardDto> cards) {
        return cards
                .stream()
                .filter(ownCard -> ownCard.getGameCardId().equalsIgnoreCase(cardId))
                .findFirst()
                .orElse(null);
    }

}
