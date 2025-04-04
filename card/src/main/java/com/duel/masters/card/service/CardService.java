package com.duel.masters.card.service;

import com.duel.masters.card.dto.DeckCardDTO;
import com.duel.masters.card.entity.Card;
import com.duel.masters.card.repository.CardRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

import static com.duel.masters.card.util.CardUtil.shuffleCards;
import static java.util.stream.Collectors.toList;

@Slf4j
@Service
@AllArgsConstructor
public class CardService {
    private final CardRepository cardRepository;


    public List<Card> getAll() {
        return cardRepository.findAll();
    }


    public List<DeckCardDTO> getNecessaryCards(List<Card> cards) {
        List<DeckCardDTO> deckCards = new ArrayList<>();
        Map<Long, Integer> cardCountMap = new HashMap<>();
        int totalCards = 0;

        while (totalCards < 40) {
            // Pick a random card from the list
            Card card = cards.get(new Random().nextInt(cards.size()));
            Long cardId = card.getId();

            // Get current count or default to 0
            int currentCount = cardCountMap.getOrDefault(cardId, 0);

            // If under 4, add it
            if (currentCount < 4) {
                cardCountMap.put(cardId, currentCount + 1);
                totalCards++;
            }
        }

        // Convert map to list of DTOs
        for (Map.Entry<Long, Integer> entry : cardCountMap.entrySet()) {
            deckCards.add(DeckCardDTO.builder()
                    .cardID(entry.getKey())
                    .quantity(entry.getValue())
                    .build());
        }

        return deckCards;
    }

}
