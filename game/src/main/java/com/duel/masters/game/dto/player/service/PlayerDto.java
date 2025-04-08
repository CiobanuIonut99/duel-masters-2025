package com.duel.masters.game.dto.player.service;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
}
