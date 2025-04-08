package com.duel.masters.game.dto.player.service;

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
public class PlayerDto {
    private Long id;
    private String username;
    private String password;
    private String country;
    private int victories;
    private int losses;

    private List<CardDto> playerHand;
    private List<CardDto> playerShields;
    private List<CardDto> playerBattleZone;
    private List<CardDto> playerManaZone;
    private List<CardDto> playerGraveyard;
    private List<CardDto> playerDeck;

}
