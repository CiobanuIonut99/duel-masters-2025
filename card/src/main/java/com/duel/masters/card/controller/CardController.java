package com.duel.masters.card.controller;

import com.duel.masters.card.entity.Card;
import com.duel.masters.card.service.CardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/cards")
public class CardController {
    private final CardService cardsService;

    public CardController(CardService cardsService) {
        this.cardsService = cardsService;
    }


    @GetMapping
    public List<Card> getCards() {
        return cardsService.getAllCards();
    }
}
