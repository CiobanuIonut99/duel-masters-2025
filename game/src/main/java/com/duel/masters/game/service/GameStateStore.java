package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class GameStateStore {
    private final Map<String, GameStateDto> gameStates =
            new ConcurrentHashMap<>();

    public void saveGameState(GameStateDto gameStateDto) {
        gameStates.put(gameStateDto.getGameId(), gameStateDto);
    }
    public GameStateDto getGameState(String gameId) {
        return gameStates.get(gameId);
    }

    public void removeGameState(String gameId) {
        gameStates.remove(gameId);
    }

    public boolean existsGameState(String gameId) {
        return gameStates.containsKey(gameId);
    }
}
