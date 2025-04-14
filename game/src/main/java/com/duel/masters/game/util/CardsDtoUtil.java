package com.duel.masters.game.util;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
public class CardsDtoUtil {
    public static CardsDto getCardsDto(List<CardDto> hand,
                                       List<CardDto> manaZone,
                                       List<CardDto> deck,
                                       List<CardDto> graveyard,
                                       List<CardDto> battleZone) {
        return
                CardsDto
                        .builder()
                        .hand(hand)
                        .manaZone(manaZone)
                        .deck(deck)
                        .graveyard(graveyard)
                        .battleZone(battleZone)
                        .build();
    }

    public static Long untappedCards(List<CardDto> cards) {
        return cards
                .stream()
                .filter(cardDto1 -> !cardDto1.isTapped())
                .count();
    }
}
