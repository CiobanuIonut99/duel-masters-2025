package com.duel.masters.game.controller;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class GameTestController {

    private final SimpMessagingTemplate simpMessagingTemplate;

    @GetMapping("/test")
    public void testGameUpdate() {
        String topic = "/topic/game/100/player2";

        // ✅ Create some fake cards
        CardDto card1 = CardDto.builder()
                .id(1L)
                .name("Bronze-Arm Tribe")
                .type("Creature")
                .civilization("Nature")
                .race("Beast Folk")
                .manaCost(3)
                .manaNumber(1)
                .ability("When you put this creature into the battle zone, put the top card of your deck into your mana zone.")
                .specialAbility("None")
                .build();

        CardDto card2 = CardDto.builder()
                .id(2L)
                .name("Aqua Guard")
                .type("Creature")
                .civilization("Water")
                .race("Cyber Virus")
                .manaCost(2)
                .manaNumber(1)
                .ability("Blocker")
                .specialAbility("None")
                .build();

        // ✅ Build a fake game state
        GameStateDto fakeGameState = GameStateDto.builder()
                .gameId("100")
                .playerId(999L)
                .playerName("FakePlayer")
                .playerTopic("player2")
                .playerHand(List.of(card1))
                .playerDeck(List.of(card2))
                .playerShields(List.of(card2))
                .opponentHand(List.of(card1))
                .opponentDeck(List.of(card2))
                .opponentShields(List.of(card1))
                .currentTurnPlayerId(999L)
                .build();

        // ✅ Send it to the topic
        simpMessagingTemplate.convertAndSend(topic, fakeGameState);
        System.out.println("📤 Sent fake game state to " + topic);
    }
}
