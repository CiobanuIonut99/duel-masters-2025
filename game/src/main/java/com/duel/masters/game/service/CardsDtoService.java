package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsUtil.getCardsDto;

@Service
@Slf4j
public class CardsDtoService {

    public boolean isPlayer(GameStateDto currentState, GameStateDto incomingDto) {
        return currentState.getPlayerId().equals(incomingDto.getPlayerId());
    }

    public CardsDto getOwnCards(GameStateDto currentState, GameStateDto incomingDto) {
        final var isPlayer = isPlayer(currentState, incomingDto);
        var hand = isPlayer ? currentState.getPlayerHand() : currentState.getOpponentHand();
        var manaZone = isPlayer ? currentState.getPlayerManaZone() : currentState.getOpponentManaZone();
        var deck = isPlayer ? currentState.getPlayerDeck() : currentState.getOpponentDeck();
        var graveyard = isPlayer ? currentState.getPlayerGraveyard() : currentState.getOpponentGraveyard();
        var battleZone = isPlayer ? currentState.getPlayerBattleZone() : currentState.getOpponentBattleZone();

        return getCardsDto(hand, manaZone, deck, graveyard, battleZone);
    }

    public CardsDto getOpponentCards(GameStateDto currentState, GameStateDto incomingDto) {
        final var isPlayer = isPlayer(currentState, incomingDto);
        var hand = isPlayer ? currentState.getOpponentHand() : currentState.getPlayerHand();
        var manaZone = isPlayer ? currentState.getOpponentManaZone() : currentState.getPlayerManaZone();
        var deck = isPlayer ? currentState.getOpponentDeck() : currentState.getPlayerDeck();
        var graveyard = isPlayer ? currentState.getOpponentGraveyard() : currentState.getPlayerGraveyard();
        var battleZone = isPlayer ? currentState.getOpponentBattleZone() : currentState.getPlayerBattleZone();

        return getCardsDto(hand, manaZone, deck, graveyard, battleZone);
    }
}
