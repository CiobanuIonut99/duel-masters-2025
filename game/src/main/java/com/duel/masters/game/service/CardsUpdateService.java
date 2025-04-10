package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsUpdateDto;
import com.duel.masters.game.dto.GameStateDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class CardsUpdateService {

    public boolean isPlayer(GameStateDto currentState, GameStateDto incomingDto) {
        return currentState.getPlayerId().equals(incomingDto.getPlayerId());
    }

    public CardsUpdateDto getOwnCards(GameStateDto currentState, boolean isPlayer) {
        var hand = isPlayer ? currentState.getPlayerHand() : currentState.getOpponentHand();
        var manaZone = isPlayer ? currentState.getPlayerManaZone() : currentState.getOpponentManaZone();
        var deck = isPlayer ? currentState.getPlayerDeck() : currentState.getOpponentDeck();
        var graveyard = isPlayer ? currentState.getPlayerGraveyard() : currentState.getOpponentGraveyard();
        var battleZone = isPlayer ? currentState.getPlayerBattleZone() : currentState.getOpponentBattleZone();
        return
                CardsUpdateDto
                        .builder()
                        .hand(hand)
                        .manaZone(manaZone)
                        .deck(deck)
                        .graveyard(graveyard)
                        .battleZone(battleZone)
                        .build();
    }

    public CardsUpdateDto getOpponentCards(GameStateDto currentState, GameStateDto incomingDto, boolean isPlayer) {
        var hand = isPlayer ? currentState.getOpponentHand() : currentState.getPlayerHand();
        var manaZone = isPlayer ? currentState.getOpponentManaZone() : currentState.getPlayerManaZone();
        var deck = isPlayer ? currentState.getOpponentDeck() : currentState.getPlayerDeck();
        var graveyard = isPlayer ? currentState.getOpponentGraveyard() : currentState.getPlayerGraveyard();
        var battleZone = isPlayer ? currentState.getOpponentBattleZone() : currentState.getPlayerBattleZone();
        return
                CardsUpdateDto
                        .builder()
                        .hand(hand)
                        .manaZone(manaZone)
                        .deck(deck)
                        .graveyard(graveyard)
                        .battleZone(battleZone)
                        .build();
    }
}
