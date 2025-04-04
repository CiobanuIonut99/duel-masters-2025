package com.duel.masters.player.controller;

import com.duel.masters.player.dto.PlayerDto;
import com.duel.masters.player.service.PlayerService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/players")
@AllArgsConstructor
public class PlayerController {

    private PlayerService playerService;

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<PlayerDto> getAll() {
        return playerService.getAll();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<Void> create(@Valid @RequestBody PlayerDto playerDto) {
        playerService.create(playerDto);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

}
