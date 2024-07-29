import 'dart:async';
import 'dart:collection';

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:whisper/characters/zombie.dart';

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

mixin SimpleMovement2 on SimpleEnemy {
  Queue<Point16> targets = Queue();

  Completer<void>? onReachTarget;
  bool isPatrolling = false;
  double patrolSpeed = 1;
  bool isPaused = false;
  int visitedCheckpoints = 0;

  Future<void> patrol(
    List<Point16> checkpoints, {
    double patrolSpeed = 0.5,
  }) {
    visitedCheckpoints = 0;
    targets = Queue.of(checkpoints);
    isPatrolling = true;
    isPaused = false;
    onReachTarget = Completer();
    this.patrolSpeed = patrolSpeed;
    return onReachTarget!.future;
  }

  void pausePatrolling() {
    isPaused = true;
  }

  void resumePatrolling() {
    isPaused = false;
  }

  @override
  void update(double dt) {
    final target = targets.firstOrNull;
    if (isPaused || target == null) {
      super.update(dt);
      return;
    }

    final currPoint = Point16.fromMapPos(absoluteCenter);
    if (currPoint == target) {
      visitedCheckpoints++;
      targets.removeFirst();
      // print('Reached $target, next: ${targets.firstOrNull}');

      if (isPatrolling) targets.addLast(target);
      if (targets.isEmpty ||
          (isPatrolling && targets.length == visitedCheckpoints)) {
        onReachTarget?.complete();
        onReachTarget = null;
        if (!isPatrolling) stopMove();
      }
    } else {
      moveToPoint(target);
    }

    super.update(dt);
  }

  void moveToPoint(Point16 point) => moveToPosition(
        point.mapPosition + Vector2.all(8),
        speed: isPatrolling ? speed * patrolSpeed : null,
      );

  Future<void> moveToTarget(Point16 target) {
    if (targets.length == 1 && target == targets.first) {
      return onReachTarget!.future;
    }

    onReachTarget = Completer();
    isPatrolling = false;
    return onReachTarget!.future;
  }

  Future<void> followPath(List<Point16> path) {
    targets = Queue.of(path);
    isPatrolling = false;
    onReachTarget = Completer();
    return onReachTarget!.future;
  }
}
