package com.duel.masters.game.mock;

import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

@Service
@Slf4j
@AllArgsConstructor
public class MockService {
    public void mockShields(List<CardDto> deck,
                            List<CardDto> shields,
                            List<CardDto> hand,
                            Long futureShieldId) {
        var soonToBeShield = new CardDto();
        boolean foundInHand = false;
        boolean foundInDeck = false;

        for (var card : hand) {
            if (Objects.equals(card.getId(), futureShieldId)) {
                soonToBeShield = card;
                foundInHand = true;
            }
        }

        for (var deckCard : deck) {
            if (Objects.equals(deckCard.getId(), futureShieldId)) {
                soonToBeShield = deckCard;
                foundInDeck = true;
            }
        }

        if (foundInHand) {
            var cardRemovedFromShield = shields.removeFirst();
            shields.add(soonToBeShield);

            hand.remove(soonToBeShield);
            hand.add(cardRemovedFromShield);

        }

        if (foundInDeck) {
            var cardRemovedFromShield = shields.removeFirst();
            shields.add(soonToBeShield);

            deck.remove(soonToBeShield);
            deck.add(cardRemovedFromShield);

        }

    }

    public void mockHand(List<CardDto> deck,
                         List<CardDto> hand,
                         Long futureHandId) {

        var cardDto = deck
                .stream()
                .filter(card -> card.getId().equals(futureHandId))
                .findFirst()
                .orElseThrow();

        hand.add(cardDto);
        deck.remove(cardDto);

    }
}
