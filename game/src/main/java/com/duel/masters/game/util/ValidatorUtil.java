package com.duel.masters.game.util;

import com.duel.masters.game.dto.card.service.CardDto;

import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.untappedCards;

public class ValidatorUtil {

    public static boolean checkAtLeastOneCardSameCivilizationPresent(List<CardDto> manaZone, CardDto cardDto) {
        return manaZone
                .stream()
                .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()));

    }

    public static boolean isSummonable(List<CardDto> manaZOne, CardDto card) {
        return checkAtLeastOneCardSameCivilizationPresent(manaZOne, card) &&
                untappedCards(manaZOne) >= card.getManaCost();
    }
}
