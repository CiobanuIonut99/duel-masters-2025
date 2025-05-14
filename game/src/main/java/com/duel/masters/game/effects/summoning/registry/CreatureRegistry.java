package com.duel.masters.game.effects.summoning.registry;

import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.effects.summoning.IocantTheOracle;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class CreatureRegistry {
    private static final Map<String, Effect> creatureEffects = new ConcurrentHashMap<>();

    static {
        creatureEffects.put("Iocant, the Oracle", new IocantTheOracle());
    }

    public static Effect getCreatureEffect(String name) {
        return creatureEffects.get(name);
    }

    public static Set<String> getCreatureEffectNames() {
        return creatureEffects.keySet();
    }
}
