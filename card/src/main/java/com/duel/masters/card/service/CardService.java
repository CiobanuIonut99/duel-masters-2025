package com.duel.masters.card.service;

import com.duel.masters.card.entity.Card;
import com.duel.masters.card.repository.CardRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
public class CardService {
    private final CardRepository cardsRepository;

    public CardService(CardRepository cardsRepository) {
        this.cardsRepository = cardsRepository;
    }
    public List<Card> getAllCards() {
        return cardsRepository.findAll();
    }
}
