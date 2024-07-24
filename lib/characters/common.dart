import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';

class PlayerSpriteSheet {
  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
        "knight_idle.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
        "knight_run.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleRight: idleRight,
        runRight: runRight,
      );
}

extension Patrol on RandomMovement {
  void patrol(KeyLocation location, final double dt) {
    final List<Direction> allowedDirections = [];
    final Vector2 currPos = absoluteCenter.clone();

    for (final dir in Direction.values) {
      final dirVec2 = dir.toVector2();
      final nextLoc = currPos + dirVec2 * 32;
      final nextPoint = Point16.fromMapPos(nextLoc);
      final isValid = location.contains(nextPoint);
      // print('${Point16.fromMapPos(currPos)} ${dir.name} -> $nextPoint, $isValid');
      if (isValid) allowedDirections.add(dir);
    }

    if (allowedDirections.isNotEmpty) {
      runRandomMovement(
        dt,
        directions: RandomMovementDirections(values: allowedDirections),
        timeKeepStopped: 500,
      );
    }
  }
}
