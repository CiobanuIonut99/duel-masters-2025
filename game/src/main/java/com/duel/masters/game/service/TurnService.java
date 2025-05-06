package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.summoning.registry.CreatureRegistry;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.util.CardsDtoUtil.*;

@Slf4j
@Service
@AllArgsConstructor
public class TurnService {

    private final TopicService topicService;
    private final CardsUpdateService cardsUpdateService;


    public void endTurn(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        log.info("Current player ends turn");
        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var opponentDeck = opponentCards.getDeck();
        var opponentHand = opponentCards.getHand();
        var opponentManaZone = opponentCards.getManaZone();
        var opponentBattleZone = opponentCards.getBattleZone();

        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);
        var ownBattleZone = ownCards.getBattleZone();

        currentState.setPlayedMana(false);
        currentState.setCurrentTurnPlayerId(incomingState.getOpponentId());
        drawCard(opponentDeck, opponentHand);
        untapOpponentsCards(opponentManaZone);
        untapOpponentsCards(opponentBattleZone);
        setCardsSummonable(opponentManaZone, opponentHand);
        setOpponentsCreaturesCanAttack(opponentBattleZone);
        cureOpponentsCreaturesSickness(opponentBattleZone);
        opponentBattleZone.forEach(cardDto -> cardDto.setCanBeAttacked(false));
        setOpponentsCreaturesAttackable(cardsUpdateService.getOwnCards(currentState, incomingState).getBattleZone());

        ownBattleZone
                .stream()
                .filter(ownCard -> ownCard.getId().equals(2L))
                .forEach(ownCard -> {
                    var creatureEffect = CreatureRegistry
                            .getCreatureEffect(ownCard.getName());
                    creatureEffect.execute(currentState, incomingState, cardsUpdateService);
                });

        topicService.sendGameStatesToTopics(currentState, webSocketHandler);
    }
}
