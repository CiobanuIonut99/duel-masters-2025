package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)

public class GameStateDto {

    private String gameId;
    private String triggeredGameCardId;

    private Long playerId;
    private Long opponentId;

    private String playerName;
    private String opponentName;

    private String playerTopic;
//    private String opponentTopic;

    private Long currentTurnPlayerId;

    private String action;

    private List<CardDto> playerBattleZone = new CopyOnWriteArrayList<>();
    private List<CardDto> playerHand = new CopyOnWriteArrayList<>();
    private List<CardDto> playerShields = new CopyOnWriteArrayList<>();
    private List<CardDto> playerManaZone = new CopyOnWriteArrayList<>();
    private List<CardDto> playerGraveyard = new CopyOnWriteArrayList<>();
    private List<CardDto> playerDeck = new CopyOnWriteArrayList<>();

    private List<CardDto> opponentHand = new CopyOnWriteArrayList<>();
    private List<CardDto> opponentShields = new CopyOnWriteArrayList<>();
    private List<CardDto> opponentBattleZone = new CopyOnWriteArrayList<>();
    private List<CardDto> opponentManaZone = new CopyOnWriteArrayList<>();
    private List<CardDto> opponentGraveyard = new CopyOnWriteArrayList<>();
    private List<CardDto> opponentDeck = new CopyOnWriteArrayList<>();
}
