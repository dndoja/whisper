import 'package:bonfire/bonfire.dart';

import 'common.dart';

class ShadowPlayer extends SimplePlayer {
  ShadowPlayer(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(16),
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        );
}
