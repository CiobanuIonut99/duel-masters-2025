package com.duel.masters.game.service;

import com.duel.masters.game.dto.DeckCardDto;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.dto.deck.service.DeckDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

@Slf4j
@Service
@AllArgsConstructor
public class GameService {

    private final RestClient.Builder restClientBuilder;
    private final ObjectMapper objectMapper;

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

    public DeckCardDto getDeckCardDto() {
        var deckDto = getDeckCard();
        var deck = deckDto.getCards();
        var shields = get5Cards(deck);
        var hand = get5Cards(deck);

        return DeckCardDto.builder()
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
