package com.duel.masters.game.service;

import com.duel.masters.game.dto.player.service.PlayerDto;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.locks.ReentrantLock;

@Service
public class MatchmakingService {

    private final Queue<PlayerDto> waitingPlayers = new ConcurrentLinkedQueue<>();
    private final ReentrantLock lock = new ReentrantLock();

    public Optional<List<PlayerDto>> tryMatchPlayer(PlayerDto player) {
        lock.lock();
        try {
            waitingPlayers.add(player);

            if (waitingPlayers.size() >= 2) {
                PlayerDto player1 = waitingPlayers.poll();
                PlayerDto player2 = waitingPlayers.poll();

                // Extra safety in case one was removed externally
                if (player1 != null && player2 != null) {
                    return Optional.of(List.of(player1, player2));
                } else {
                    // One was missing — put the non-null one back
                    if (player1 != null) waitingPlayers.add(player1);
                    if (player2 != null) waitingPlayers.add(player2);
                }
            }

            return Optional.empty();
        } finally {
            lock.unlock();
        }
    }
}
