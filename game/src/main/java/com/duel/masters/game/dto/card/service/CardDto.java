package com.duel.masters.game.dto.card.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CardDto {
    private Long id;
    private String gameCardId;
    private String name;
    private String type;
    private String civilization;
    private String race;
    private int manaCost;
    private int manaNumber;
    private int power;
    private String ability;
    private String specialAbility;
    private boolean tapped;
    private boolean summonable;
    private boolean summoningSickness;
    private boolean canBeAttacked;
    private boolean canAttack;
    private boolean shield;
    private boolean destroyed;

}
