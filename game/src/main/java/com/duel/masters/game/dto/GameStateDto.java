package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
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

    private List<CardDto> playerHand;
    private List<CardDto> playerShields;
    private List<CardDto> playerBattleZone;
    private List<CardDto> playerManaZone;
    private List<CardDto> playerGraveyard;
    private List<CardDto> playerDeck;

    private List<CardDto> opponentHand;
    private List<CardDto> opponentShields;
    private List<CardDto> opponentBattleZone;
    private List<CardDto> opponentManaZone;
    private List<CardDto> opponentGraveyard;
    private List<CardDto> opponentDeck;
}
