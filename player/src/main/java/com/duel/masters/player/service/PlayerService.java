package com.duel.masters.player.service;

import com.duel.masters.player.dto.PlayerDto;
import com.duel.masters.player.mapper.PlayerMapper;
import com.duel.masters.player.repository.PlayerRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class PlayerService {
    private PlayerRepository playerRepository;

    public List<PlayerDto> getAll() {
        return playerRepository.findAll()
                .stream()
                .map(PlayerMapper::toPlayerDto)
                .toList();
    }

    public void create(PlayerDto playerDto) {
        playerRepository.save(PlayerMapper.toPlayer(playerDto));
    }
}
