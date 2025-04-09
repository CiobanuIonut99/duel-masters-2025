package com.duel.masters.game.controller;

import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.GameService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@AllArgsConstructor
@Slf4j
public class GameWebSocketController {

    private final GameService gameService;

    @MessageMapping("game")
    public void startGame(PlayerDto player) {
    gameService.startGame(player);
    }
}
