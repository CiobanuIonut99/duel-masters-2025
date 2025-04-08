package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class GameWebSocketController {

    @MessageMapping("match")
    @SendTo("topic/game")
    public GameStateDto match(PlayerDto player) {
        return GameStateDto
                .builder()
                .gameId("match123")
                .playerId(player.getId())
                .build();
    }

}
