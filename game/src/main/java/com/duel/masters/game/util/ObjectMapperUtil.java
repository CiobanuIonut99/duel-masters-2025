package com.duel.masters.game.util;

import com.duel.masters.game.dto.GameStateDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@Slf4j
public class ObjectMapperUtil {
    private static final ObjectMapper mapper = new ObjectMapper();

    public static GameStateDto convertToGameStateDto(Map<String, Object> gameStateDto) {
        try {
            GameStateDto dto = mapper.convertValue(gameStateDto, GameStateDto.class);
            return dto;
        } catch (Exception e) {
            log.error("❌ Failed to convert to GameStateDto", e);
            throw new RuntimeException("Failed to convert to GameStateDto", e);
        }
    }
}
