package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.GameLogicService;
import com.duel.masters.game.service.GameService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

@Controller
@AllArgsConstructor
@Slf4j
public class GameWebSocketController {

    private final GameService gameService;
    private final GameLogicService gameLogicService;

    @MessageMapping("/game/start")

    public void startGame(PlayerDto player) {
        gameService.startGame(player);
    }

    @MessageMapping("/game/action")
    public void doAction(@Payload GameStateDto gameStateDto) {
        log.info("doAction");
        log.info("gameStateDto: {}", gameStateDto);
        gameLogicService.doAction(gameStateDto);
    }

}
