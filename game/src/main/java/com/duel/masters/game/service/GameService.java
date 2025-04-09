package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDto;

@Slf4j
@Service
@AllArgsConstructor
public class GameService {

    private final MatchmakingService matchmakingService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    public void startGame(PlayerDto playerDto) {
        log.info("Matching player ..." + playerDto.getUsername());
        log.info("Player shield number : {} ", playerDto.getPlayerShields().size());
        log.info("Player hand number : {} ", playerDto.getPlayerHand().size());
        log.info("Player deck number : {} ", playerDto.getPlayerDeck().size());

        matchmakingService
                .tryMatchPlayer(playerDto)
                .ifPresent(
                        playerList -> {
                            String gameId = UUID.randomUUID().toString();
                            var player = playerList.get(0);
                            var opponent = playerList.get(1);

                            var gameState1 = getGameStateDto(gameId, player, opponent, PLAYER_1_TOPIC);
                            var gameState2 = getGameStateDto(gameId, opponent, player, PLAYER_2_TOPIC);

                            simpMessagingTemplate.convertAndSend(
                                    MATCHMAKING_TOPIC,
                                    List.of(gameState1, gameState2)
                            );
                            log.info("sent to general topic : topic/matchmaking");
                            var topic1 = GAME_TOPIC + gameId + SLASH + PLAYER_1_TOPIC;
                            var topic2 = GAME_TOPIC + gameId + SLASH + PLAYER_2_TOPIC;
                            sendGameStatesToTopics(topic1, gameState1, topic2, gameState2, player, opponent);
                        });
    }

    private void sendGameStatesToTopics(String topic1,
                                        GameStateDto gameState1,
                                        String topic2,
                                        GameStateDto gameState2,
                                        PlayerDto player,
                                        PlayerDto opponent) {
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                simpMessagingTemplate.convertAndSend(topic1, gameState1);
                simpMessagingTemplate.convertAndSend(topic2, gameState2);
                log.info("✅ Sent to topic1: {}", topic1);
                log.info("✅ Sent to topic2: {}", topic2);
                log.info("🎮 Match players {} vs {}", player.getUsername(), opponent.getUsername());
            }
        }, 2000);
    }
}
