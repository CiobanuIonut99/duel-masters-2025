package com.duel.masters.game.dto;

import com.duel.masters.game.dto.card.service.CardDto;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ShieldTriggersFlagsDto {

    private boolean targetShield;
    private boolean shieldTrigger;
    private boolean chosenAnyCards;

    private boolean brainSerumMustDrawCards;
    private boolean crystalMemoryMustDrawCard;
    private boolean solarRayMustSelectCreature;
    private boolean spiralGateMustSelectCreature;
    private boolean darkReversalMustSelectCreature;
    private boolean ghostTouchMustSelectCreature;
    private boolean terrorPitMustSelectCreature;
    private boolean tornadoFlameMustSelectCreature;
    private boolean dimensionalGateMustDrawCard;
    private boolean naturalSnareMustSelectCreature;

    private boolean shieldTriggerDecisionMade;
    private Map<String, List<CardDto>> eachPlayerBattleZone = new ConcurrentHashMap<>();
    private List<String> cardsChosen = new CopyOnWriteArrayList<>();

}
