package com.duel.masters.game.controller;

import com.duel.masters.game.exception.AlreadyPlayedManaException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(AlreadyPlayedManaException.class)
    public ResponseEntity<String> handleAlreadyPlayedManaException(AlreadyPlayedManaException e) {
        return ResponseEntity.status(500).body("Mana already played!");
    }
}
