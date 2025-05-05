package com.duel.masters.game.service;

import com.duel.masters.game.dto.InitialStateDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.dto.deck.service.DeckDto;
import com.duel.masters.game.mock.MockService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@AllArgsConstructor
public class InitialStateService {
    private final RestClient.Builder restClientBuilder;
    private final ObjectMapper objectMapper;
    private final MockService mockService;

    public DeckDto getDeckCard() {
        log.info("Start getDeckCard in GameService");

        try {
            final var result = restClientBuilder
                    .baseUrl("http://deck-service")
                    .build()
                    .get()
                    .uri("/api/decks/random")
                    .retrieve()
                    .toEntity(String.class);

            return objectMapper.readValue(result.getBody(), DeckDto.class);

        } catch (Exception e) {
            log.error("Failed to fetch deck from deck-service: {}", e.getMessage(), e);
            throw new RuntimeException("Deck service unavailable", e);
        }
    }

    public InitialStateDto getInitialState() {
        var deckDto = getDeckCard();
        var deck = deckDto.getCards();
        var shields = get5Cards(deck);
        var hand = get5Cards(deck);

//        mockService.mockShields(deck, shields, hand, 16L);
//        mockService.mockShields(deck, shields, hand, 29L);
        mockService.mockShields(deck, shields, hand, 37L);
//        mockService.mockShields(deck, shields, hand, 50L);
//        mockService.mockShields(deck, shields, hand, 62L);
//        mockService.mockShields(deck, shields, hand, 64L);
//        mockService.mockShields(deck, shields, hand, 39L);
        mockService.mockShields(deck, shields, hand, 73L);
        mockService.mockShields(deck, shields, hand, 98L);
        mockService.mockShields(deck, shields, hand, 103L);
        mockService.mockShields(deck, shields, hand, 109L);

        log.info("Deck has {} cards", deck.size());
        log.info("Shields has {} cards", shields.size());
        log.info("Hand has {} cards", hand.size());

        shields.forEach(shield -> {
                    shield.setCanBeAttacked(true);
                    shield.setShield(true);
                }
        );

        return InitialStateDto.builder()
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
