package com.duel.masters.game.deck.service;

import com.duel.masters.game.card.service.CardService;
import com.duel.masters.game.dto.card.service.CardDto;
import com.duel.masters.game.dto.deck.service.DeckDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;

import static com.duel.masters.game.deck.util.DeckUtil.shuffleCards;

@AllArgsConstructor
@Service
@Slf4j
public class DeckService {
    private final CardService cardService;

    public DeckDto generateRandomDeck() {

        Random random = new Random();
        int copiesOfCards;
        List<CardDto> deck = new ArrayList<>();
        List<CardDto> cardDtoList = cardService.getDM01();
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

