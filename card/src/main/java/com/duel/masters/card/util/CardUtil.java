package com.duel.masters.card.util;

import com.duel.masters.card.entity.Card;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Slf4j
@Component
public class CardUtil {

    public static void shuffleCards(List<Card> cards) {
        log.info("Shuffling Cards");
        Collections.shuffle(cards);
    }
}
