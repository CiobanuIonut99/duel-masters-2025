package com.duel.masters.deck.util;

import com.duel.masters.deck.dto.CardDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Slf4j
@Component
public class DeckUtil {
    public static void shuffleCards(List<CardDto> cards) {
        log.info("Shuffling Cards");
        Collections.shuffle(cards);
    }
}
