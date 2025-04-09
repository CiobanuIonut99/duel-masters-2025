package com.duel.masters.deck.service;

import com.duel.masters.deck.dto.CardDto;
import com.duel.masters.deck.dto.DeckDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;

import static com.duel.masters.deck.util.DeckUtil.shuffleCards;

@Slf4j
@Service
@AllArgsConstructor
public class DeckService {

    private final RestClient.Builder restClientBuilder;
    private final ObjectMapper objectMapper;

    public List<CardDto> getDM01() {
        log.info("getDM01 in DeckService");

        try {
            final var result = restClientBuilder
                    .baseUrl("http://card-service")
                    .build()
                    .get()
                    .uri("/api/cards")
                    .retrieve()
                    .toEntity(String.class);

            return objectMapper.readValue(result.getBody(), new TypeReference<>() {
            });

        } catch (Exception e) {
            log.error("Failed to fetch cards from card-service: {}", e.getMessage(), e);
            throw new RuntimeException("Card service unavailable", e);
        }
    }

    public DeckDto generateRandomDeck() {
        Random random = new Random();
        int copiesOfCards;
        List<CardDto> deck = new ArrayList<>();
        List<CardDto> cardDtoList = getDM01();
        shuffleCards(cardDtoList);

        for (CardDto cardDto : cardDtoList) {
            copiesOfCards = random.nextInt(0, 5);
            switch (copiesOfCards) {
                case 0 -> {
                    continue;
                }
                case 1 -> addCardToDeck(deck, cardDto, 1);
                case 2 -> {
                    if (deck.size() > 38)
                        break;
                    addCardToDeck(deck, cardDto, 2);
                }
                case 3 -> {
                    if (deck.size() > 37)
                        break;
                    addCardToDeck(deck, cardDto, 3);
                }
                case 4 -> {
                    if (deck.size() > 36)
                        break;
                    addCardToDeck(deck, cardDto, 4);
                }
            }
            if (deck.size() >= 40)
                break;
        }
        assignGameCardId(deck);
        shuffleCards(deck);
        return
                DeckDto
                        .builder()
                        .name("RANDOM DECK")
                        .id(1)
                        .cards(deck)
                        .build();
    }

    public void addCardToDeck(List<CardDto> cards, CardDto cardDto, int copiesOfCards) {
        for (int i = 0; i < copiesOfCards; i++) {
            cards.add(cardDto);
        }
    }

    public void assignGameCardId(List<CardDto> cards) {
        cards.forEach(card -> card.setGameCardId(UUID.randomUUID().toString()));
    }
}
