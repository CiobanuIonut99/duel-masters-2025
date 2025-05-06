package com.duel.masters.game.effects.summoning.registry;

import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.effects.summoning.AquaSniperEffect;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class CreatureImmediateEffectRegistry {
    private static final Map<String, Effect> creatureImmediateEffects = new ConcurrentHashMap<>();

    static {
        creatureImmediateEffects.put("Aqua Sniper", new AquaSniperEffect());
    }

    public static Effect getCreatureEffect(String name) {
        return creatureImmediateEffects.get(name);
    }

    public static Set<String> getCreatureEffectNames() {
        return creatureImmediateEffects.keySet();
    }
}
