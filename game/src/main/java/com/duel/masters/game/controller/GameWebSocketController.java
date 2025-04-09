package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.GameLogicService;
import com.duel.masters.game.service.GameService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@AllArgsConstructor
@Slf4j
@MessageMapping("game")
public class GameWebSocketController {

    private final GameService gameService;
    private final GameLogicService gameLogicService;

    @MessageMapping("/start")

    public void startGame(PlayerDto player) {
        gameService.startGame(player);
    }

    @MessageMapping("/action")
    public void doAction(GameStateDto gameStateDto) {
        gameLogicService.doAction(gameStateDto);
    }
}
