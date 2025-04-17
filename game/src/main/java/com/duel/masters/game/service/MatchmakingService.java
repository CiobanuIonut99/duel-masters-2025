package com.duel.masters.game.service;

import com.duel.masters.game.dto.player.service.PlayerDto;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

@Service
public class MatchmakingService {

    private final Queue<PlayerDto> waitingPlayers = new ConcurrentLinkedQueue<>();
    private final Lock lock = new ReentrantLock();

    public Optional<List<PlayerDto>> tryMatchPlayer(PlayerDto player) {
        lock.lock();
        try {
            PlayerDto opponent = waitingPlayers.poll();
            if (opponent != null) {
                return Optional.of(List.of(player, opponent));
            } else {
                waitingPlayers.offer(player);
                return Optional.empty();
            }
        } finally {
            lock.unlock();
        }
    }
}
