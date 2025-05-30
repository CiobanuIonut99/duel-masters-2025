package com.duel.masters.game.service;

import com.duel.masters.game.deck.service.DeckService;
import com.duel.masters.game.dto.InitialStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@AllArgsConstructor
public class InitialStateService {

    private final DeckService deckService;

    public InitialStateDto getInitialState() {
        var deckDto = deckService.generateRandomDeck();
        var deck = deckDto.getCards();
        var shields = get5Cards(deck);
        var hand = get5Cards(deck);

        log.info("Deck has {} cards", deck.size());
        log.info("Shields has {} cards", shields.size());
        log.info("Hand has {} cards", hand.size());

        shields
                .forEach(shield -> {
                    shield.setCanBeAttacked(true);
                    shield.setShield(true);
                }
        );

        return InitialStateDto
                .builder()
                .deck(deck)
                .shields(shields)
                .hand(hand)
                .build();
    }

    private List<CardDto> get5Cards(List<CardDto> deck) {
        List<CardDto> cards = new ArrayList<>();
        for (int i = 0; i < 5; i++) {
            var card = deck.get(i);
            cards.add(card);
            deck.remove(card);
        }
        return cards;
    }

}
