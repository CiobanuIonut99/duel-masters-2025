package com.duel.masters.card.controller;

import com.duel.masters.card.dto.DeckCardDTO;
import com.duel.masters.card.entity.Card;
import com.duel.masters.card.service.CardService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/cards")
@AllArgsConstructor
public class CardController {
    private final CardService cardService;

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<Card> getAll() {
        return cardService.getAll();
    }

    @GetMapping("/deck")
    public List<DeckCardDTO> getDeckCards() {
        return cardService.getNecessaryCards();
    }

}
