import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';

import 'common.dart';

class ShadowPlayer extends SimplePlayer {
  LinePathComponent? _linePathComponent;

  ShadowPlayer(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(16),
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        );

  @override
  void update(double dt) {
    // final closest = characterTracker.allAlive.minBy((c) => c.distance(this));
    // if (closest != null) {
    //   final dir = Vector2(closest.x - x, closest.y - y).normalized();
    //   final dist = distance(closest);
    //   // printUnique(dir.toString());
    //
    //   final raycastResult = raycast(
    //     dir,
    //     ignoreHitboxes: closest.shapeHitboxes,
    //     maxDistance: distance(closest),
    //   );
    //   showLine(
    //     absoluteCenter,
    //     absoluteCenter + (dir * dist),
    //     raycastResult != null ? Colors.red : Colors.blue,
    //   );
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
