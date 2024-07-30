import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/decorations/shadow_target.dart';

import 'animations.dart';

class ShadowPlayer extends SimplePlayer {
  LinePathComponent? _linePathComponent;

  ShadowPlayer(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(24),
          animation: Animations.forCharacter(
            CharacterSheet.monsters,
            3,
            null,
            invertHorizontal: true,
          ),
        );

  bool summoned = false;

  @override
  Future<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // final point = Point16.fromMapPos(absoluteCenter);
    // if (point == KeyLocation.ritualSite.ref && !summoned){
    //   summoned = true;
    //   gameRef.add(RitualEclipseLight());
    // }

    final closest = characterTracker.allAlive.minBy((c) => c.distance(this));
    if (closest != null) {
      final dist = distance(closest);
      if (dist < 100) {
        shadowTarget.target = closest;
      } else {
        shadowTarget.target = null;
      }
      final attack = AttackAnimation.fromAngle(getAngleFromTarget(closest));
      final dir =
          attack == AttackAnimation.left ? Direction.left : Direction.right;

      // if (closest != null) {
      //   final dir = Vector2(closest.x - x, closest.y - y).normalized();
      //   // printUnique(dir.toString());
      //
      //   final raycastResult = raycast(
      //     dir,
      //     ignoreHitboxes: closest.shapeHitboxes,
      //     maxDistance: distance(closest),
      //   );
      // showLine(
      //   absoluteCenter,
      //   absoluteCenter + (dir.toVector2() * dist),
      //   Colors.red,
      // );
    }
    // }
    super.update(dt);
  }

  void showLine(Vector2 loc1, Vector2 loc2, Color color) {
    if (_linePathComponent != null) {
      _linePathComponent!.removeFromParent();
      _linePathComponent = null;
    }

    _linePathComponent = LinePathComponent([loc1, loc2], color, 5);
    gameRef.add(_linePathComponent!);
  }
}
