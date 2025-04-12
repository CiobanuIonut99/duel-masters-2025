package com.duel.masters.game.controller;

import com.duel.masters.game.dto.InitialStateDto;
import com.duel.masters.game.service.InitialStateService;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/games")
@AllArgsConstructor
public class GameController {
    private final InitialStateService initialStateService;

    @GetMapping
    public InitialStateDto getInitialState() throws JsonProcessingException {
        return initialStateService.getInitialState();
    }
}
