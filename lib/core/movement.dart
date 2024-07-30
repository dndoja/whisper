import 'dart:async';
import 'dart:collection';

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:whisper/characters/undead.dart';

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
      print('$currPoint -> $target');
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

  void moveToPoint(Point16 point) => moveToPosition(point.mapPosition);

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
  int visitedCheckpoints = 0;
  bool _isPaused = false;
  double pathSpeed = 1;

  Future<void> patrol(
    List<Point16> checkpoints, {
    double patrolSpeed = 0.5,
  }) {
    visitedCheckpoints = 0;
    targets = Queue.of(checkpoints);
    isPatrolling = true;
    _isPaused = false;
    onReachTarget = Completer();
    this.patrolSpeed = patrolSpeed;
    return onReachTarget!.future;
  }

  void pausePatrolling({bool forceStop = false}) {
    _isPaused = true;
    if (forceStop) stopMove();
  }

  void resumePatrolling() => _isPaused = false;

  @override
  void update(double dt) {
    final target = targets.firstOrNull;
    if (_isPaused || target == null) {
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
      _moveToPoint(target);
    }

    super.update(dt);
  }

  void _moveToPoint(Point16 point) => moveToPosition(
        point.mapPosition,
        speed: speed * (isPatrolling ? patrolSpeed : pathSpeed),
      );

  Future<void> moveToTarget(Point16 target) {
    if (targets.length == 1 && target == targets.first) {
      return onReachTarget!.future;
    }

    onReachTarget = Completer();
    _isPaused = false;
    isPatrolling = false;
    pathSpeed = 1;
    return onReachTarget!.future;
  }

  Future<void> followPath2(List<(int, int)> path, {double speed = 1}) =>
      followPath(path.map((p) => Point16(p.$1, p.$2)), speed: speed);

  Future<void> followPath(Iterable<Point16> path, {double speed = 1}) {
    pathSpeed = speed;
    targets = Queue.of(path);
    isPatrolling = false;
    onReachTarget = Completer();
    return onReachTarget!.future;
  }
}
