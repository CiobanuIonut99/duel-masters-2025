package com.duel.masters.game.util;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;

import java.util.HashSet;
import java.util.List;

import static com.duel.masters.game.util.CardsUtil.getNumberOfUntappedCardsInManaZone;


public class Validator {
    public static boolean hasSameCivilizationInMana(List<CardDto> manaZone, CardDto cardDto) {
        return
                manaZone
                        .stream()
                        .anyMatch(card -> card.getCivilization().equalsIgnoreCase(cardDto.getCivilization()));
    }

    public static boolean hasEnoughUntappedMana(Long numberOfUntappedCardsInManaZone, CardDto cardDto) {
        return
                numberOfUntappedCardsInManaZone >= cardDto.getManaCost();
    }

    public static boolean manaCardsToPayForSummonEqualsManaCost(List<CardDto> manaCardsToPayForSummon, CardDto cardDto) {
        return
                manaCardsToPayForSummon.size() == cardDto.getManaCost();
    }

    public static boolean manaContainsAllSelectedCards(List<String> manaZoneCardIds, List<String> triggeredGameCardIds) {
        return
                new HashSet<>(manaZoneCardIds).containsAll(triggeredGameCardIds);
    }

    public static boolean isCardSummonable(CardDto cardDto, List<CardDto> manaZone) {
        var hasEnoughUntappedMana =
                hasEnoughUntappedMana(getNumberOfUntappedCardsInManaZone(manaZone), cardDto);

        return
                hasSameCivilizationInMana(manaZone, cardDto) &&
                        hasEnoughUntappedMana;

    }

    public static boolean canSummonToBattleZone(
            CardDto cardToBeSummoned,
            List<CardDto> manaZone,
            List<String> manaZoneCardIds,
            List<CardDto> manaCardsToPayForSummon,
            GameStateDto incomingDto) {
        return
                isCardSummonable(cardToBeSummoned, manaZone) &&
                        manaContainsAllSelectedCards(manaZoneCardIds, incomingDto.getTriggeredGameCardIds()) &&
                        manaCardsToPayForSummonEqualsManaCost(manaCardsToPayForSummon, cardToBeSummoned);
    }


}
