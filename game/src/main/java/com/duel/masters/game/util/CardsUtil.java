package com.duel.masters.game.util;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

@Slf4j
public class CardsUtil {
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

    public static List<CardDto> getManaCardsToPayForSummon(List<String> selectedManaIds,
                                                                             List<CardDto> manaZone) {

        List<CardDto> manaCardsToPayForSummon = new ArrayList<>();
        for (CardDto manaCardDto : manaZone) {
            for (String selectedManaCardId : selectedManaIds) {
                if (manaCardDto.getGameCardId().equals(selectedManaCardId)) {
                    manaCardsToPayForSummon.add(manaCardDto);
                }
            }
        }
        return manaCardsToPayForSummon;
    }

    public static List<String> getManaZoneCardsIds(List<CardDto> manaZone) {
        return
                manaZone
                        .stream()
                        .map(CardDto::getGameCardId)
                        .toList();
    }

    public static CardDto getCardToBeSummonedByTriggeredId(List<CardDto> hand, String triggeredId) {
        return
                hand
                        .stream()
                        .filter(cardDto ->
                                cardDto.getGameCardId().equals(triggeredId))
                        .findAny()
                        .orElseThrow();
    }

    public static Long getNumberOfUntappedCardsInManaZone(List<CardDto> manaZone) {
        return
                manaZone
                        .stream()
                        .filter(Predicate.not(CardDto::isTapped))
                        .count();
    }

}
