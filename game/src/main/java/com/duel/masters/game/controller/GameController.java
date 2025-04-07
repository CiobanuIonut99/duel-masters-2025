package com.duel.masters.game.controller;

import com.duel.masters.game.dto.DeckCardDto;
import com.duel.masters.game.service.GameService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("api/games")
@AllArgsConstructor
@CrossOrigin("*")
public class GameController {
    private final GameService gameService;

    @GetMapping
    public DeckCardDto getDeckCard() {
        return gameService.getDeckCardDto();
    }
}
