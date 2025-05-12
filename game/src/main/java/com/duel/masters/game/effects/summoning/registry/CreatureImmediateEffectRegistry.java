package com.duel.masters.game.effects.summoning.registry;

import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.effects.summoning.AquaSniperEffect;
import com.duel.masters.game.effects.summoning.ScarletSkyterrorEffect;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class CreatureImmediateEffectRegistry {
    private static final Map<String, Effect> creatureImmediateEffects = new ConcurrentHashMap<>();
    private static final Map<String, Effect> powerAttacker = new ConcurrentHashMap<>();

    static {
        creatureImmediateEffects.put("Aqua Sniper", new AquaSniperEffect());
        creatureImmediateEffects.put("Scarlet Skyterror", new ScarletSkyterrorEffect());

        powerAttacker.put("PA_2000", new CreaturePA2K());
        powerAttacker.put("PA_4000", new CreaturePA4K());
    }

    public static Effect getCreatureEffect(String name) {
        return creatureImmediateEffects.get(name);
    }

    public static Set<String> getCreatureEffectNames() {
        return creatureImmediateEffects.keySet();
    }

    public static Effect getCreaturePowerAttackerEffect(String name) {
        return powerAttacker.get(name);
    }

    public static Set<String> getPowerAttackerAbility() {
        return powerAttacker.keySet();
    }
}
