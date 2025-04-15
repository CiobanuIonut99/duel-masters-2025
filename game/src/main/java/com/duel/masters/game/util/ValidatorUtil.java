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

    public static boolean isValidForSummoning(List<CardDto> manaZone, List<String> selectedManaCardIds, List<CardDto> selectedManaCards, CardDto cardToBeSummoned) {
        var atLeastOneSelectedManaCardHasNecessaryCivilization = false;
        var countUntapped = 0;
        for (CardDto manaCardDto : manaZone) {
            for (String selectedManaCardId : selectedManaCardIds) {
                if (manaCardDto.getGameCardId().equals(selectedManaCardId)) {
                    selectedManaCards.add(manaCardDto);

                    if (!manaCardDto.isTapped()) {
                        countUntapped++;
                    }

                    if (manaCardDto.getCivilization().equals(cardToBeSummoned.getCivilization())) {
                        atLeastOneSelectedManaCardHasNecessaryCivilization = true;
                    }
                }
            }
        }

        return atLeastOneSelectedManaCardHasNecessaryCivilization && countUntapped == cardToBeSummoned.getManaCost();

    }
}

