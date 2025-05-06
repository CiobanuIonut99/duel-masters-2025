package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.getCardsDto;

@Service
@Slf4j
public class CardsUpdateService {

    public static boolean isPlayer(GameStateDto currentState, GameStateDto incomingState) {
        return currentState.getPlayerId().equals(incomingState.getPlayerId());
    }

    public CardsDto getOwnCards(GameStateDto currentState, GameStateDto incomingState) {
        final var isPlayer = isPlayer(currentState, incomingState);
        var hand = isPlayer ? currentState.getPlayerHand() : currentState.getOpponentHand();
        var manaZone = isPlayer ? currentState.getPlayerManaZone() : currentState.getOpponentManaZone();
        var deck = isPlayer ? currentState.getPlayerDeck() : currentState.getOpponentDeck();
        var graveyard = isPlayer ? currentState.getPlayerGraveyard() : currentState.getOpponentGraveyard();
        var battleZone = isPlayer ? currentState.getPlayerBattleZone() : currentState.getOpponentBattleZone();
        var shields = isPlayer ? currentState.getPlayerShields() : currentState.getOpponentShields();

        return getCardsDto(hand, manaZone, deck, graveyard, battleZone, shields);
    }

    public CardsDto getOpponentCards(GameStateDto currentState, GameStateDto incomingState) {
        final var isPlayer = isPlayer(currentState, incomingState);
        var hand = isPlayer ? currentState.getOpponentHand() : currentState.getPlayerHand();
        var manaZone = isPlayer ? currentState.getOpponentManaZone() : currentState.getPlayerManaZone();
        var deck = isPlayer ? currentState.getOpponentDeck() : currentState.getPlayerDeck();
        var graveyard = isPlayer ? currentState.getOpponentGraveyard() : currentState.getPlayerGraveyard();
        var battleZone = isPlayer ? currentState.getOpponentBattleZone() : currentState.getPlayerBattleZone();
        var shields = isPlayer ? currentState.getOpponentShields() : currentState.getPlayerShields();

        return getCardsDto(hand, manaZone, deck, graveyard, battleZone, shields);
    }
}
