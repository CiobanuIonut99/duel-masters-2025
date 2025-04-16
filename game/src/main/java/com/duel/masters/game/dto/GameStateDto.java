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
    private String attackerId;
    private String targetId;
    private List<String> triggeredGameCardIds;

    private Long playerId;
    private Long opponentId;

    private String playerName;
    private String opponentName;

    private boolean playedMana;
    private boolean canBlock;

    private String playerTopic;

    private Long currentTurnPlayerId;

    private boolean targetShield;
    private boolean opponentHasBlocker = false;
    private boolean hasSelectedBlocker = false;

    private String action;
    @Builder.Default
    private List<CardDto> playerBattleZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerHand = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerShields = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerManaZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerGraveyard = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> playerDeck = new CopyOnWriteArrayList<>();
    @Builder.Default

    private List<CardDto> opponentHand = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> opponentShields = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> opponentBattleZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> opponentManaZone = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> opponentGraveyard = new CopyOnWriteArrayList<>();
    @Builder.Default
    private List<CardDto> opponentDeck = new CopyOnWriteArrayList<>();
}
