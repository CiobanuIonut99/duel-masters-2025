package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.MatchmakingService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.UUID;

@Controller
@AllArgsConstructor
@Slf4j
public class GameWebSocketController {

    private final MatchmakingService matchmakingService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @MessageMapping("match")
    public void match(PlayerDto player) {

        log.info("Match player " + player);
        matchmakingService
                .tryMatchPlayer(player)
                .ifPresent(
                        playerList -> {
                            String gameId = UUID.randomUUID().toString();
                            var player1 = playerList.get(0);
                            var player2 = playerList.get(1);

                            var gameState1 = GameStateDto.builder()
                                    .gameId(gameId)
                                    .playerId(player1.getId())
                                    .opponentId(player2.getId())
                                    .playerName(player1.getUsername())
                                    .opponentName(player2.getUsername())
                                    .currentTurnPlayerId(player1.getId())
                                    .build();

                            var gameState2 = GameStateDto.builder()
                                    .gameId(gameId)
                                    .playerId(player2.getId())
                                    .opponentId(player1.getId())
                                    .playerName(player2.getUsername())
                                    .opponentName(player1.getUsername())
                                    .currentTurnPlayerId(player1.getId())
                                    .build();

                            simpMessagingTemplate.convertAndSendToUser(
                                    player1.getId().toString(),
                                    "/queue/game",
                                    gameState1);

                            simpMessagingTemplate.convertAndSendToUser(
                                    player2.getId().toString(),
                                    "/queue/game",
                                    gameState2);
                        });

    }
}
