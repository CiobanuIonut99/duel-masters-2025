package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class DeckCardDto {

    private List<CardDto> deck;
    private List<CardDto> shields;
    private List<CardDto> hand;

}
