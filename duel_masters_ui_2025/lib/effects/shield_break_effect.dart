import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class ShieldBreakEffect extends SpriteAnimationComponent {
  ShieldBreakEffect({required Vector2 screenSize})
      : super(
    position: screenSize / 2 - Vector2.all(250), // center on screen
    size: Vector2.all(500), // 5x bigger animation
  );

  @override
  Future<void> onLoad() async {
    try {
      print('Loading shield break animation...');
      final images = await Future.wait(
        List.generate(
          64,
              (i) => Flame.images.load('animations/shield/shield_$i.png'),
        ),
      );

      final sprites = images.map((img) => Sprite(img)).toList();

      animation = SpriteAnimation.spriteList(
        sprites,
        stepTime: 0.1, // 1 second per frame (5 total)
        loop: false,
      );

      print('Shield break animation loaded successfully!');
    } catch (e) {
      print('Error loading animation: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animationTicker?.done() == true) {
      print('Animation done. Removing from parent.');
      removeFromParent();
    }
  }
}
