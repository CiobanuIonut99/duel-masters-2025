package com.duel.masters.deck.service;

import com.duel.masters.deck.dto.CardDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import static com.duel.masters.deck.util.DeckUtil.shuffleCards;

@Slf4j
@Service
@AllArgsConstructor
public class DeckService {

    private final RestClient.Builder restClientBuilder;

    public List<CardDto> getDM01() {
        try {
            final var result = restClientBuilder
                    .baseUrl("http://card-service")
                    .build()
                    .get()
                    .uri("/api/cards")
                    .retrieve()
                    .toEntity(String.class);
            return new ObjectMapper().readValue(result.getBody(), new TypeReference<>() {
            });
        }  catch (Exception e) {
            log.error("Failed to fetch cards from card-service: {}", e.getMessage(), e);
            throw new RuntimeException("Card service unavailable", e);
        }
    }

    public List<CardDto> generateRandomDeck() {
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
                case 1 -> deck.add(cardDto);
                case 2 -> {
                    if (deck.size() > 38)
                        break;
                    deck.add(cardDto);
                    deck.add(cardDto);
                }
                case 3 -> {
                    if (deck.size() > 37)
                        break;
                    deck.add(cardDto);
                    deck.add(cardDto);
                    deck.add(cardDto);
                }
                case 4 -> {
                    if (deck.size() > 36)
                        break;
                    deck.add(cardDto);
                    deck.add(cardDto);
                    deck.add(cardDto);
                    deck.add(cardDto);
                }
            }
            if (deck.size() >= 40)
                break;
        }
        return deck;
    }
}
