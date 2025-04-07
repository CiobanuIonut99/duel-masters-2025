package com.duel.masters.card.controller;

import com.duel.masters.card.dto.CardDto;
import com.duel.masters.card.service.CardService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/cards")
@AllArgsConstructor
public class CardController {
    private final CardService cardService;

    @GetMapping
    public List<CardDto> getAll() {
        return cardService.getDM01();
    }
}
