package com.duel.masters.card.mapper;

import com.duel.masters.card.dto.CardDto;
import com.duel.masters.card.model.Card;

public class CardMapper {

    public static CardDto toCardDto(Card card) {
        return CardDto.builder()
                .id(card.getId())
                .name(card.getName())
                .type(card.getType() != null ? card.getType().name() : null)
                .civilization(card.getCivilization() != null ? card.getCivilization().name() : null)
                .race(card.getRace())
                .manaCost(card.getManaCost())
                .manaNumber(card.getManaNumber())
                .power(card.getPower())
                .ability(card.getAbility())
                .specialAbility(card.getSpecialAbility() != null ? card.getSpecialAbility().name() : null)
                .build();
    }
}
