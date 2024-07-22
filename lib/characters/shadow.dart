import 'package:flame/components.dart';
import 'package:whisper/game.dart';

class TheShadow extends SpriteAnimationComponent with HasGameRef<WhisperGame> {
  TheShadow({
    required super.position,
  }) : super(size: Vector2.all(300), anchor: Anchor.center);

  @override
  void onLoad() {
    print('loading the shadow');
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('shadow.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        textureSize: Vector2(64,70),
        texturePosition: Vector2(14, 17),
        stepTime: 0.12,
      ),
    );
  }
}
