package com.duel.masters.game.service;

import com.duel.masters.game.dto.player.service.PlayerDto;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

@Service
public class MatchmakingService {
    private final Queue<PlayerDto> waitingPlayers = new ConcurrentLinkedQueue<>();

    public Optional<List<PlayerDto>> tryMatchPlayer(PlayerDto player) {
        waitingPlayers.add(player);

        if (waitingPlayers.size() >= 2) {
            PlayerDto player1 = waitingPlayers.poll();
            PlayerDto player2 = waitingPlayers.poll();
            return Optional.of(List.of(player1, player2));
        }

        return Optional.empty(); // Still waiting
    }

}
