package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

public interface ShieldTriggerEffect {
    void execute(GameStateDto currentState,
                 GameStateDto incomingState,
                 CardsUpdateService cardsUpdateService);
}
