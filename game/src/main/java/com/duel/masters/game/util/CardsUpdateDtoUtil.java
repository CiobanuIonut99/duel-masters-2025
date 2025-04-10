package com.duel.masters.game.util;

import com.duel.masters.game.dto.CardsUpdateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
public class CardsUpdateDtoUtil {
    public static CardsUpdateDto getCardsUpdateDto(List<CardDto> hand,
                                                   List<CardDto> manaZone,
                                                   List<CardDto> deck,
                                                   List<CardDto> graveyard,
                                                   List<CardDto> battleZone) {
        return
                CardsUpdateDto
                        .builder()
                        .hand(hand)
                        .manaZone(manaZone)
                        .deck(deck)
                        .graveyard(graveyard)
                        .battleZone(battleZone)
                        .build();
    }
}
