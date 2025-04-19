package com.duel.masters.game.effects;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class ShieldTriggerRegistry {
    private static final Map<String, ShieldTriggerEffect> shieldTriggerEffects = new ConcurrentHashMap<>();

    static {
        shieldTriggerEffects.put("Holy Awe", new HolyAweEffect());
    }

    public static ShieldTriggerEffect getShieldTriggerEffect(String name) {
        return shieldTriggerEffects.get(name);
    }
}
