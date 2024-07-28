import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';

String? lastPrinted;
void printUnique(String str) {
  if (str == lastPrinted) return;
  print(str);
  lastPrinted = str;
}

extension RotateRight on Direction {
  Direction opposite() => switch (this) {
        Direction.left => Direction.right,
        Direction.upLeft => Direction.downRight,
        Direction.upRight => Direction.downLeft,
        Direction.downRight => Direction.upLeft,
        Direction.downLeft => Direction.upRight,
        Direction.right => Direction.left,
        Direction.up => Direction.down,
        Direction.down => Direction.up,
      };

  Direction cardinal() => switch (this) {
        Direction.left => Direction.left,
        Direction.upLeft => Direction.left,
        Direction.upRight => Direction.right,
        Direction.downRight => Direction.right,
        Direction.downLeft => Direction.left,
        Direction.right => Direction.right,
        Direction.up => Direction.up,
        Direction.down => Direction.down,
      };

  List<Direction> get components => switch (this) {
        Direction.upLeft => const [Direction.up, Direction.left],
        Direction.upRight => const [Direction.up, Direction.right],
        Direction.downRight => const [Direction.down, Direction.right],
        Direction.downLeft => const [Direction.down, Direction.left],
        _ => const [],
      };

  Direction rotateCounterClockwise() {
    switch (this) {
      case Direction.left:
        return Direction.down;
      case Direction.down:
        return Direction.right;
      case Direction.right:
        return Direction.up;
      case Direction.up:
        return Direction.left;
      case Direction.upLeft:
      case Direction.downLeft:
        return Direction.left;
      case Direction.upRight:
      case Direction.downRight:
        return Direction.right;
    }
  }

  Direction rotateClockwise() {
    switch (this) {
      case Direction.left:
        return Direction.up;
      case Direction.up:
      case Direction.upLeft:
      case Direction.upRight:
        return Direction.right;
      case Direction.right:
        return Direction.down;
      case Direction.down:
      case Direction.downRight:
      case Direction.downLeft:
        return Direction.left;
    }
  }

  bool get isLeftIsh =>
      this == Direction.left ||
      this == Direction.upLeft ||
      this == Direction.downLeft;

  bool get isRightIsh =>
      this == Direction.right ||
      this == Direction.upRight ||
      this == Direction.downRight;
}

class KeyLocationComponent extends GameComponent {
  KeyLocationComponent([this._keyLocation]);

  KeyLocation? _keyLocation;
  KeyLocation? get keyLocation => _keyLocation;

  set keyLocation(KeyLocation? keyLocation) {
    _keyLocation = keyLocation;
    position = keyLocation?.ref.mapPosition ?? Vector2.zero();
  }
}

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
