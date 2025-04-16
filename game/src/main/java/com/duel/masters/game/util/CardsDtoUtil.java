package com.duel.masters.game.util;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

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
        return cards
                .stream()
                .filter(cardDto -> cardDto.getGameCardId().equals(cardId))
                .findFirst()
                .orElseThrow();
    }

    public static List<CardDto> getSelectedManaCards(List<CardDto> manaZone, List<String> selectedManaCardIds) {
        var selectedManaCards = new ArrayList<CardDto>();

        for (CardDto manaCardDto : manaZone) {
            for (String selectedManaCardId : selectedManaCardIds) {
                if (manaCardDto.getGameCardId().equals(selectedManaCardId)) {
                    selectedManaCards.add(manaCardDto);
                }
            }
        }
        return selectedManaCards;
    }

    public static List<String> getCardIds(List<CardDto> cards) {
        return cards
                .stream()
                .map(CardDto::getGameCardId)
                .toList();
    }

    public static void setCreaturesAttackable(List<CardDto> cards) {
        cards.stream().filter(CardDto::isTapped).forEach(cardDto -> cardDto.setCanBeAttacked(true));
    }

    public static void setCreaturesCanAttack(List<CardDto> cards) {
        cards.forEach(cardDto -> cardDto.setCanAttack(true));
    }

    public static void untapCards(List<CardDto> cards) {
        cards.forEach(card -> card.setTapped(false));
    }

    public static void tapCards(List<CardDto> cards) {
        cards.forEach(card -> card.setTapped(true));
    }

    public static void cureSickness(List<CardDto> cards) {
        cards
                .stream()
                .filter(CardDto::isSummoningSickness)
                .forEach(cardDto -> cardDto.setSummoningSickness(false));
    }
}
