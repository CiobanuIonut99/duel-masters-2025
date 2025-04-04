package com.duel.masters.player.service;

import com.duel.masters.player.model.Player;
import com.duel.masters.player.repository.PlayerRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class PlayerService {
    private PlayerRepository playerRepository;

    public List<Player> getAll(){
        return playerRepository.findAll();
    }

    public void create(Player player){
        playerRepository.save(player);
    }
}
