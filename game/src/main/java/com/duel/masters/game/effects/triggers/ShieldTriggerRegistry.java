package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.effects.Effect;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class ShieldTriggerRegistry {
    private static final Map<String, Effect> shieldTriggerEffects = new ConcurrentHashMap<>();

    static {
        shieldTriggerEffects.put("Holy Awe", new HolyAweEffect());
        shieldTriggerEffects.put("Solar Ray", new SolarRayEffect());
        shieldTriggerEffects.put("Brain Serum", new BrainSerumEffect());
        shieldTriggerEffects.put("Crystal Memory", new CrystalMemoryEffect());
        shieldTriggerEffects.put("Spiral Gate", new SpiralGateEffect());
        shieldTriggerEffects.put("Dark Reversal", new DarkReversalEffect());
        shieldTriggerEffects.put("Ghost Touch", new GhostTouchEffect());
        shieldTriggerEffects.put("Terror Pit", new TerrorPitEffect());
        shieldTriggerEffects.put("Tornado Flame", new TornadoFlameEffect());
        shieldTriggerEffects.put("Dimension Gate", new DimensionGateEffect());
        shieldTriggerEffects.put("Natural Snare", new NaturalSnareEffect());
    }

    public static Effect getShieldTriggerEffect(String name) {
        return shieldTriggerEffects.get(name);
    }
}
