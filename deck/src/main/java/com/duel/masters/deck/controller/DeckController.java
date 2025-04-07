package com.duel.masters.deck.controller;

import com.duel.masters.deck.dto.CardDto;
import com.duel.masters.deck.service.DeckService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/decks")
@AllArgsConstructor
public class DeckController {

    private final DeckService deckService;

    @GetMapping("/random")
    public List<CardDto> getRandomDeck() {
        return deckService.generateRandomDeck();
    }
}
