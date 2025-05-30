package com.duel.masters.game.card.mapper;


import com.duel.masters.game.card.model.Card;
import com.duel.masters.game.dto.card.service.CardDto;

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
