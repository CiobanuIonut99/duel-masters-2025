package com.duel.masters.game.dto.card.service;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Builder
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
    @JsonAlias("isTapped")
    private boolean isTapped;
    private boolean summonable;
}
