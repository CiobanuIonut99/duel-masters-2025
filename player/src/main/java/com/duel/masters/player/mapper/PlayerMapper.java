package com.duel.masters.player.mapper;

import com.duel.masters.player.dto.PlayerDto;
import com.duel.masters.player.model.Player;

public class PlayerMapper {

    public static PlayerDto toPlayerDto(Player player) {
        return PlayerDto
                .builder()
                .id(player.getId())
                .username(player.getUsername())
                .country(player.getCountry())
                .victories(player.getVictories())
                .losses(player.getLosses())
                .build();
    }

    public static Player toPlayer(PlayerDto playerDto) {
        return Player
                .builder()
                .username(playerDto.getUsername())
                .password(playerDto.getPassword())
                .country(playerDto.getCountry())
                .build();
    }
}
