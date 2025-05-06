package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.dto.player.service.PlayerDto;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GameStateDto {

    //added for unity raw websocket
    private String type;
    private PlayerDto playerDto;

    private String gameId;
    private String targetId;
    private String attackerId;
    private String triggeredGameCardId;
    private List<String> triggeredGameCardIds;

    private Long playerId;
    private Long opponentId;
    private Long currentTurnPlayerId;

    private String playerName;
    private String opponentName;

    private boolean playedMana;
    private boolean canBlock;

    private String playerTopic;

    private boolean usingShieldTrigger;
    private CardDto shieldTriggerCard;

    private boolean opponentHasBlocker;
    private boolean hasSelectedBlocker;

    private String action;

    private BlockerFlagsDto blockerFlagsDto;
    private ShieldTriggersFlagsDto shieldTriggersFlagsDto;
    private List<CardDto> opponentSelectableCreatures;
    private List<CardDto> playerBattleZone;
    private List<CardDto> playerHand;
    private List<CardDto> playerShields;
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
