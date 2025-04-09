package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.GameLogicService;
import com.duel.masters.game.service.GameService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

import java.util.Map;

@Controller
@AllArgsConstructor
@Slf4j
public class GameWebSocketController {

    private final GameService gameService;
    private final GameLogicService gameLogicService;

    @MessageMapping("/game/start")
    public void startGame(@Payload  PlayerDto player) {
        gameService.startGame(player);
    }

    @MessageMapping("/game/action")
    public void doAction(@Payload Map<String, Object> payload) {
        log.info("doAction");
        log.info("gameStateDto: {}", payload);
        gameLogicService.doAction(payload);
    }
    @MessageExceptionHandler
    public void handleError(Throwable ex) {
        log.error("WebSocket error: {}", ex.getMessage(), ex);
    }

}
