package com.duel.masters.game.dto.card.service;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class CardDto {
    private Long id;
    private String name;
    private String type;
    private String civilization;
    private String race;
    private int manaCost;
    private int manaNumber;
    private int power;
    private String ability;
    private String specialAbility;
}
