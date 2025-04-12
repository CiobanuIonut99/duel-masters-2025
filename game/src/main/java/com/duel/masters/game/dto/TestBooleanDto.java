package com.duel.masters.game.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class TestBooleanDto {
    private boolean atLeastOneSelectedManaCardHasNecessaryCivilization;
    private int countUntappedManaCards;
}
