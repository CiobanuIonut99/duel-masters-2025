package com.duel.masters.game.util;

import com.duel.masters.game.dto.card.service.CardDto;

import java.util.HashSet;
import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.untappedCards;

public class ValidatorUtil {
    public static boolean checkAtLeastOneCardSameCivilizationPresent(List<CardDto> manaZone, CardDto cardDto) {
        return manaZone
                .stream()
                .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()) &&
                        !card.isTapped());
    }

    public static boolean isSummonable(List<CardDto> manaZone, CardDto card) {
        return checkAtLeastOneCardSameCivilizationPresent(manaZone, card) &&
                untappedCards(manaZone) >= card.getManaCost();
    }

    public static boolean canSummon(List<String> manaZoneGameCardIds,
                                           List<String> selectedManaCardIds,
                                           List<CardDto> manaZone,
                                           CardDto cardToBeSummoned) {
        return new HashSet<>(manaZoneGameCardIds).containsAll(selectedManaCardIds) &&
                manaZone.size() >= selectedManaCardIds.size() &&
                selectedManaCardIds.size() == cardToBeSummoned.getManaCost() &&
                isSummonable(manaZone, cardToBeSummoned);
    }
}


