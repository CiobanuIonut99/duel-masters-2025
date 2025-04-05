package com.duel.masters.card.service;

import com.duel.masters.card.dto.DeckCardDTO;
import com.duel.masters.card.entity.Card;
import com.duel.masters.card.repository.CardRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@AllArgsConstructor
public class CardService {
    private final CardRepository cardRepository;


    public List<Card> getAll() {
        return cardRepository.findAll();
    }


    public List<DeckCardDTO> getNecessaryCards() {
        var cards = getAll();
        List<DeckCardDTO> deckCards = new ArrayList<>();
        Map<Long, Integer> cardCountMap = new HashMap<>();
        int totalCards = 0;

        while (totalCards < 40) {
            Card card = cards.get(new Random().nextInt(cards.size()));
            Long cardId = card.getId();

            int currentCount = cardCountMap.getOrDefault(cardId, 0);

            if (currentCount < 4) {
                cardCountMap.put(cardId, currentCount + 1);
                totalCards++;
            }
        }

        for (Map.Entry<Long, Integer> entry : cardCountMap.entrySet()) {
            deckCards.add(DeckCardDTO.builder()
                    .cardID(entry.getKey())
                    .quantity(entry.getValue())
                    .build());
        }

        return deckCards;
    }

}
