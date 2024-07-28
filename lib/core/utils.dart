import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'chase.dart';

String? lastPrinted;
void printUnique(String str) {
  if (str == lastPrinted) return;
  print(str);
  lastPrinted = str;
}

Future<void> wrapInFuture(Function(Function()) fn) {
  final Completer<void> completer = Completer();
  fn(() => completer.complete());
  return completer.future;
}

extension ChaseFuture on ChaseMovement {
  Future<void> chase(Npc target) =>
      wrapInFuture((onFinish) => chaseTarget(target, onFinish: onFinish));
}

extension RotateRight on Direction {
  Direction get opposite => switch (this) {
        Direction.left => Direction.right,
        Direction.upLeft => Direction.downRight,
        Direction.upRight => Direction.downLeft,
        Direction.downRight => Direction.upLeft,
        Direction.downLeft => Direction.upRight,
        Direction.right => Direction.left,
        Direction.up => Direction.down,
        Direction.down => Direction.up,
      };

  Direction get cardinal => switch (this) {
        Direction.left => Direction.left,
        Direction.upLeft => Direction.left,
        Direction.upRight => Direction.right,
        Direction.downRight => Direction.right,
        Direction.downLeft => Direction.left,
        Direction.right => Direction.right,
        Direction.up => Direction.up,
        Direction.down => Direction.down,
      };

  List<Direction> get cardinalComponents => switch (this) {
        Direction.upLeft => const [Direction.up, Direction.left],
        Direction.upRight => const [Direction.up, Direction.right],
        Direction.downRight => const [Direction.down, Direction.right],
        Direction.downLeft => const [Direction.down, Direction.left],
        _ => [this],
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
