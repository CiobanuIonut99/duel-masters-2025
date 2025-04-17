package com.duel.masters.game.util;

import com.duel.masters.game.dto.card.service.CardDto;

import java.util.HashSet;
import java.util.List;

import static com.duel.masters.game.util.CardsDtoUtil.untappedCards;

public class ValidatorUtil {
    public static boolean checkAtLeastOneCardSameCivilizationPresent(List<CardDto> cards, CardDto cardDto) {
        return cards
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
                                    List<CardDto> selectedManaCards,
                                    CardDto cardToBeSummoned) {
        return new HashSet<>(manaZoneGameCardIds).containsAll(selectedManaCardIds) &&
                selectedManaCardIds.size() == cardToBeSummoned.getManaCost() &&
                untappedCards(manaZone) >= cardToBeSummoned.getManaCost() &&
                checkAtLeastOneCardSameCivilizationPresent(selectedManaCards, cardToBeSummoned);
    }

    public static boolean battleZoneHasAtLeastOneBlocker(List<CardDto> battleZone) {
        return battleZone
                .stream()
                .anyMatch(cardDto -> cardDto.getSpecialAbility().equalsIgnoreCase("BLOCKER") &&
                        !cardDto.isTapped());
    }
}


