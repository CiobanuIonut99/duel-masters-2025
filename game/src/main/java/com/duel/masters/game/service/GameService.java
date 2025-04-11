package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.GameStateUtil.getGameStateDto;

@Slf4j
@Service
@AllArgsConstructor
public class GameService {

    private final MatchmakingService matchmakingService;
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final GameStateStore gameStateStore;

    public void startGame(PlayerDto playerDto) {
        log.info(playerDto.getUsername().concat(" is searching for an opponent  ..."));

        matchmakingService
                .tryMatchPlayer(playerDto)
                .ifPresent(
                        playerList -> {
                            String gameId = UUID.randomUUID().toString();
                            var player = playerList.get(0);
                            var opponent = playerList.get(1);
                            var randomPlayer = new Random().nextInt(1, 3);
                            var isPlayer1Chosen = randomPlayer == 1;

                            var gameStatePlayer = getGameStateDto(gameId, player, opponent, isPlayer1Chosen, PLAYER_1_TOPIC);
                            var gameStateOpponent = getGameStateDto(gameId, opponent, player, !isPlayer1Chosen, PLAYER_2_TOPIC);
                            var gameStates = List.of(gameStatePlayer, gameStateOpponent);

                            gameStateStore.saveGameState(gameStatePlayer);
                            simpMessagingTemplate.convertAndSend(MATCHMAKING_TOPIC, gameStates);

                            log.info("sent to general topic : topic/matchmaking");

                            var topic1 = GAME_TOPIC + gameId + SLASH + PLAYER_1_TOPIC;
                            var topic2 = GAME_TOPIC + gameId + SLASH + PLAYER_2_TOPIC;

                            sendGameStatesToTopics(topic1, gameStatePlayer, topic2, gameStateOpponent, player, opponent);
                        });
    }

    private void sendGameStatesToTopics(String topic1,
                                        GameStateDto gameStatePlayer,
                                        String topic2,
                                        GameStateDto gameStateOpponent,
                                        PlayerDto player,
                                        PlayerDto opponent) {
        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                simpMessagingTemplate.convertAndSend(topic1, gameStatePlayer);
                simpMessagingTemplate.convertAndSend(topic2, gameStateOpponent);
                log.info("✅ Sent to topic1: {}", topic1);
                log.info("✅ Sent to topic2: {}", topic2);
                log.info("🎮 Matched players {} vs {}", player.getUsername(), opponent.getUsername());
            }
        }, 2000);
    }
}
