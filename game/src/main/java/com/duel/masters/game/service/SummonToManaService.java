package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.exception.AlreadyPlayedManaException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;
import static com.duel.masters.game.util.CardsDtoUtil.setCardsSummonable;

@Slf4j
@Service
@AllArgsConstructor
public class SummonToManaService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;

    public void summonCardToManaZone(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        if (!currentState.isPlayedMana()) {
            var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
            playCard(ownCards.getHand(), incomingState.getTriggeredGameCardId(), ownCards.getManaZone());
            setCardsSummonable(ownCards.getManaZone(), ownCards.getHand());
            currentState.setPlayedMana(true);
        } else {
            throw new AlreadyPlayedManaException();
        }
        topicService.sendGameStatesToTopics(currentState, webSocketHandler);
    }
}
