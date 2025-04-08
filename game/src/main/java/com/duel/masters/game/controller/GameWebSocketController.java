package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.duel.masters.game.service.MatchmakingService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

@Controller
@AllArgsConstructor
@Slf4j
public class GameWebSocketController {

    private final MatchmakingService matchmakingService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @MessageMapping("match")
    public void match(PlayerDto player) {
        log.info("Matching player ..." + player.getUsername());
        log.info("Player shield number : {} ", player.getPlayerShields().size());
        log.info("Player hand number : {} ", player.getPlayerHand().size());
        log.info("Player deck number : {} ", player.getPlayerDeck().size());

        matchmakingService
                .tryMatchPlayer(player)
                .ifPresent(
                        playerList -> {
                            String gameId = UUID.randomUUID().toString();
                            var player1 = playerList.get(0);
                            var player2 = playerList.get(1);

                            var gameState1 = GameStateDto
                                    .builder()
                                    .gameId(gameId)
                                    .playerId(player1.getId())
                                    .opponentId(player2.getId())
                                    .playerName(player1.getUsername())
                                    .opponentName(player2.getUsername())
                                    .playerShields(player1.getPlayerShields())
                                    .opponentShields(player2.getPlayerShields())
                                    .playerHand(player1.getPlayerHand())
                                    .opponentHand(player2.getPlayerHand())
                                    .playerDeck(player1.getPlayerDeck())
                                    .opponentDeck(player2.getPlayerDeck())
                                    .currentTurnPlayerId(player1.getId())
                                    .playerTopic("player1")

                                    .build();

                            var gameState2 = GameStateDto
                                    .builder()
                                    .gameId(gameId)
                                    .playerId(player2.getId())
                                    .opponentId(player1.getId())
                                    .playerName(player2.getUsername())
                                    .opponentName(player1.getUsername())
                                    .playerShields(player2.getPlayerShields())
                                    .opponentShields(player1.getPlayerShields())
                                    .playerHand(player2.getPlayerHand())
                                    .opponentHand(player1.getPlayerHand())
                                    .playerDeck(player2.getPlayerDeck())
                                    .opponentDeck(player1.getPlayerDeck())
                                    .currentTurnPlayerId(player1.getId())
                                    .playerTopic("player2")
                                    .build();


                            simpMessagingTemplate.convertAndSend(
                                    "/topic/matchmaking",
                                    List.of(gameState1, gameState2)
                            );
                            log.info("sent to general topic : topic/matchmaking");

                            var topic1 = "/topic/game/" + gameId + "/player1";
                            var topic2 = "/topic/game/" + gameId + "/player2";
                            new Timer().schedule(new TimerTask() {
                                @Override
                                public void run() {
                                    simpMessagingTemplate.convertAndSend(topic1, gameState1);
                                    simpMessagingTemplate.convertAndSend(topic2, gameState2);
                                    log.info("✅ Sent to topic1: {}", topic1);
                                    log.info("✅ Sent to topic2: {}", topic2);
                                    log.info("🎮 Match players {} vs {}", player1.getUsername(), player2.getUsername());
                                }
                            }, 1000); // delay in milliseconds
                        });

    }
}
