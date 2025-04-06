import 'package:flame/game.dart';
import '../effects/shield_break_effect.dart';
import 'package:flutter/painting.dart';

class FxGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent

  void triggerShieldBreak() {
    add(ShieldBreakEffect(screenSize: canvasSize));
  }
}
