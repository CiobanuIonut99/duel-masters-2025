package com.duel.masters.game.effects.summoning.registry;

import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.effects.summoning.ScarletSkyterrorEffect;
import com.duel.masters.game.effects.summoning.UrthPurifyingElemental;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class CreatureRegistry {
    private static final Map<String, Effect> creatureEffects = new ConcurrentHashMap<>();

    static {
        creatureEffects.put("Urth, Purifying Elemental", new UrthPurifyingElemental());
    }

    public static Effect getCreatureEffect(String name) {
        return creatureEffects.get(name);
    }
}
