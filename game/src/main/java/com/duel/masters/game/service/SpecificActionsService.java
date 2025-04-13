package com.duel.masters.game.service;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.card.service.CardDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.duel.masters.game.util.Validator.isCardSummonable;

@AllArgsConstructor
@Service
@Slf4j
public class SpecificActionsService {
    public void drawCard(CardsDto opponentCards) {
        var opponentHand = opponentCards.getHand();
        var opponentDeck = opponentCards.getDeck();
        var opponentCard = opponentDeck.getFirst();
        opponentHand.add(opponentCard);
        opponentDeck.remove(opponentCard);
        log.info("Opponent draws card");
    }

    public void untapCards(List<CardDto> cards) {
        cards.forEach(cardDto -> cardDto.setTapped(false));
    }

    public void tapCards(List<CardDto> cards) {
        cards.forEach(cardDto -> cardDto.setTapped(true));
    }

    public void setCreaturesSummonable(CardsDto cards) {
        var hand = cards.getHand();
        var manaZone = cards.getManaZone();

        if (!manaZone.isEmpty()) {
            for (CardDto cardDto : hand) {
                cardDto.setSummonable(isCardSummonable(cardDto, manaZone));
            }
        }
    }

    public void playCard(List<CardDto> source, List<CardDto> destination, String triggeredGameCardId) {
        source
                .stream()
                .filter(cardDto -> cardDto.getGameCardId().equals(triggeredGameCardId))
                .findFirst()
                .ifPresent(cardDto -> {
                    destination.add(cardDto);
                    source.remove(cardDto);
                });
    }

}
