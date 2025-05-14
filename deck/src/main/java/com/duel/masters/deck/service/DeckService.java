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
        shuffleCards(deck);


//        var holyawe = cardDtoList
//                .stream()
//                .filter(cardDto -> cardDto.getId() == 16)
//                .findFirst()
//                .orElseThrow();
//
//        var solarRay = cardDtoList
//                .stream()
//                .filter(cardDto -> cardDto.getId() == 29)
//                .findFirst()
//                .orElseThrow();

        var brainSerum = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 37)
                .findFirst()
                .orElseThrow();

        var spiralGate = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 50)
                .findFirst()
                .orElseThrow();

        var darkReversal = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 62)
                .findFirst()
                .orElseThrow();

        var ghostTouch = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 64)
                .findFirst()
                .orElseThrow();

        var terrorPit = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 73)
                .findFirst()
                .orElseThrow();

        var tornadoFlame = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 98)
                .findFirst()
                .orElseThrow();

        var dimensionGate = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 103)
                .findFirst()
                .orElseThrow();

        var naturalSnare = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 109)
                .findFirst()
                .orElseThrow();

        var urth = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 2)
                .findFirst()
                .orElseThrow();

        var aquaSniper = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 3)
                .findFirst()
                .orElseThrow();


        var deopticon = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 4)
                .findFirst()
                .orElseThrow();

        var tropice = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 52)
                .findFirst()
                .orElseThrow();

        var scarlet = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 7)
                .findFirst()
                .orElseThrow();

        var brawler = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 80)
                .findFirst()
                .orElseThrow();
        var chilias = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 11)
                .findFirst()
                .orElseThrow();
        var aqua = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 34)
                .findFirst()
                .orElseThrow();

        var a = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 12)
                .findFirst()
                .orElseThrow();
        var b = cardDtoList
                .stream()
                .filter(cardDto -> cardDto.getId() == 13)
                .findFirst()
                .orElseThrow();

        List<CardDto> cardsToAdd = new ArrayList<>();

        cardsToAdd.add(aquaSniper);
        cardsToAdd.add(scarlet);
        cardsToAdd.add(brawler);
        cardsToAdd.add(chilias);
        cardsToAdd.add(chilias);
        cardsToAdd.add(aqua);
        cardsToAdd.add(a);
        cardsToAdd.add(b);
        cardsToAdd.add(urth);

        deck.removeIf(
                c ->
                c.getId() == 3 ||
                c.getId() == 7 ||
                c.getId() == 2 ||
                c.getId() == 11 ||
                c.getId() == 34 ||
                c.getId() ==80
        );
        while (deck.size() + cardsToAdd.size() > 40) {
            deck.removeFirst(); // remove extras
        }

// Add the required cards
        deck.addAll(cardsToAdd);
        assignGameCardId(deck);
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
            var newCardDto =
                    CardDto
                            .builder()
                            .id(cardDto.getId())
                            .name(cardDto.getName())
                            .type(cardDto.getType())
                            .civilization(cardDto.getCivilization())
                            .race(cardDto.getRace())
                            .manaCost(cardDto.getManaCost())
                            .manaNumber(cardDto.getManaNumber())
                            .power(cardDto.getPower())
                            .ability(cardDto.getAbility())
                            .specialAbility(cardDto.getSpecialAbility())
                            .build();
            cards.add(newCardDto);
        }
    }

    public void assignGameCardId(List<CardDto> cards) {
        cards.forEach(card -> card.setGameCardId(UUID.randomUUID().toString()));
    }
}
