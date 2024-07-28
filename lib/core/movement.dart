import 'dart:async';

import 'package:bonfire/bonfire.dart';

import 'core.dart';

mixin SimpleMovement on SimpleEnemy {
  List<Point16> targets = const [];

  List<Point16> _patrolCheckpoints = const [];
  int targetCheckpointIndex = 0;
  Point16? target;
  Completer<void>? onReachTarget;
  bool isPatrolling = false;

  void patrol(List<Point16> checkpoints) => _patrolCheckpoints = checkpoints;

  @override
  void update(double dt) {
    final checkpoints = _patrolCheckpoints;
    final currPoint = Point16.fromMapPos(absoluteCenter);
    if (target != null) {
      // print('$currPoint -> $target');
      if (currPoint == target) {
        onReachTarget!.complete();
        target = null;
        onReachTarget = null;
        stopMove();
      } else {
        moveToPoint(target!);
      }
    } else if (checkpoints.isNotEmpty) {
      final nextTarget = checkpoints[targetCheckpointIndex];

      if (currPoint == nextTarget) {
        int index = targetCheckpointIndex + 1;
        if (index > checkpoints.length - 1) index = 0;
        targetCheckpointIndex = index;
      } else {
        moveToPoint(nextTarget);
      }
    }

    super.update(dt);
  }

  void moveToPoint(Point16 point) =>
      moveToPosition(point.mapPosition + Vector2.all(8));

  Future<void> moveToTarget(Point16 target) {
    if (target == this.target) return onReachTarget!.future;
    onReachTarget = Completer();
    this.target = target;
    return onReachTarget!.future;
  }
}
