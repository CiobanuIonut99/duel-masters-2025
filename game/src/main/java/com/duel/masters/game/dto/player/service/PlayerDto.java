package com.duel.masters.game.dto.player.service;

import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

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
    @Builder.Default
    private List<CardDto> playerHand = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerShields = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerBattleZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerManaZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerGraveyard = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerDeck = new CopyOnWriteArrayList<>();

}
