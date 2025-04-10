package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CardsUpdateDto {
    private List<CardDto> hand;
    private List<CardDto> manaZone;
    private List<CardDto> deck;
    private List<CardDto> graveyard;
    private List<CardDto> battleZone;
}
