package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.duel.masters.game.util.ValidatorUtil.isSummonable;

@Service
@AllArgsConstructor
@Slf4j
public class SpecificActionsService {

    public void drawCard(CardsDto cardsDto) {
        var deck = cardsDto.getDeck();
        var card = deck.getFirst();
        cardsDto.getHand().add(card);
        deck.remove(card);
        log.info("Opponent draws card");
    }

    public void untapCards(List<CardDto> cards) {
        cards.forEach(card -> card.setTapped(false));
    }

    public void setCreaturesSummonable(CardsDto cards) {
        var hand = cards.getHand();
        var manaZone = cards.getManaZone();

        if (!manaZone.isEmpty()) {
            for (CardDto cardDto : hand) {
                cardDto.setSummonable(isSummonable(manaZone, cardDto));
            }
        }
    }

    public void prepareTurnForOpponent(GameStateDto currentState, Long opponentId) {
        currentState.setCurrentTurnPlayerId(opponentId);
        currentState.setPlayedMana(false);
    }
}
