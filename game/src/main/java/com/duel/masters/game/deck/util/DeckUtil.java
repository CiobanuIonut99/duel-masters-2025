package com.duel.masters.game.deck.util;

import com.duel.masters.game.dto.card.service.CardDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@Component
public class DeckUtil {
    public static void shuffleCards(List<CardDto> cards) {
        log.info("Shuffling Cards");
        List<CardDto> shuffled = new ArrayList<>(cards);
        Collections.shuffle(shuffled);
    }
}
