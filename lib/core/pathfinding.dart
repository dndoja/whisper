import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import 'core.dart';

final _renderer = TextPaint(
  style: const TextStyle(
    fontSize: 16,
    color: Color(0xFF000000),
  ),
);

mixin BugNav on SimpleEnemy {
  Direction? prevDir;

  void bugPathTo(GameComponent target) {
    // final bool moved = moveTowardsTarget(target: target);
    // if (moved) return;

    final dirToTarget =
        BonfireUtil.getDirectionFromAngle(getAngleFromTarget(target));

    bool validDir(Direction dir) =>
        canMove(dir, ignoreHitboxes: target.shapeHitboxes) &&
        dir != prevDir?.opposite;

    void move(Direction dir, String label) {
      moveFromDirection(dir);
      printUnique('$prevDir -> $dir $label');
      prevDir = dir;
    }

    if (validDir(dirToTarget)) {
      move(dirToTarget, 'Target');
      return;
    }

    final List<Direction> components = dirToTarget.cardinalComponents;
    for (final dir in components) {
      if (validDir(dir)) {
        move(dir, 'Component');
        return;
      }
    }

    if (prevDir != null && canMove(prevDir!)) {
      move(prevDir!, 'Previous');
      return;
    }

    // const maxRotations = 3;
    // Direction rotatedDir = dirToTarget.cardinal;
    // int rotations = 0;
    //
    // while (rotations < maxRotations && !validDir(rotatedDir)) {
    //   rotatedDir = rotatedDir.isLeftIsh
    //       ? rotatedDir.rotateCounterClockwise()
    //       : rotatedDir.rotateClockwise();
    //
    //   rotations++;
    // }
    //
    // if (validDir(rotatedDir)) move(rotatedDir);
  }
}

extension GameCollisionSquares on BonfireGameInterface {
  Set<Point16> getCollisionSquares() =>
      collisions().map((c) => Point16.fromMapPos(c.absoluteCenter)).toSet();
}

const impassableTerrain = 1 << 31;

mixin RoguePathfinder on SimpleEnemy {
  List<List<int>> _pathingMatrix = [];
  Cartographer? _cartographer;

  void updateTargets(Iterable<GameComponent> targets) {
    _cartographer = Cartographer.fromGame(gameRef);
    _pathingMatrix = _cartographer!.generatePathingMatrix(
      targets.map((t) => Point16.fromMapPos(t.absoluteCenter)).toSet(),
    );
  }

  void followPathingMatrix() {
    final currPos = Point16.fromMapPos(absoluteCenter);

    final neighbours =
        _cartographer?.getNeighboringNodes(currPos.x, currPos.y) ?? const [];
    if (neighbours.isEmpty) return;

    final best = neighbours.minBy((n) => _pathingMatrix[n.y][n.x])!;

    if (_pathingMatrix[best.y][best.x] == impassableTerrain) return;
    moveToPosition(best.mapPosition);
  }
}

class Cartographer {
  final Set<Point16> impassablePoints;
  final int endX;
  final int endY;

  const Cartographer({
    required this.endX,
    required this.endY,
    required this.impassablePoints,
  });

  factory Cartographer.fromGame(BonfireGameInterface gameRef) {
    final size = gameRef.map.getMapSize();
    final Set<Point16> collisionPoints = {};
    final collisions = gameRef.collisions();

    // final paint = Paint()..color = Colors.red;

    for (final collision in collisions) {
      if (collision is CircleHitbox) continue;

      final point = Point16.fromMapPos(collision.absoluteCenter);
      collisionPoints.add(point);
      // gameRef.map.add(
      //   RectangleComponent.square(
      //     position: point.mapPosition,
      //     paint: paint,
      //     size: 16,
      //   ),
      // );
    }

    return Cartographer(
      endX: size.x ~/ 16,
      endY: size.y ~/ 16,
      impassablePoints: collisionPoints,
    );
  }

  List<List<int>> makeEmptyMatrix([Set<Point16> goals = const {}]) {
    final List<List<int>> matrix = [];
    for (int y = 0; y <= endY; y++) {
      matrix.add([]);
      for (int x = 0; x < endX; x++) {
        if (goals.contains(Point16(x, y))) {
          matrix[y].add(0);
        } else {
          matrix[y].add(impassableTerrain);
        }
      }
    }

    return matrix;
  }

  List<List<int>> generatePathingMatrix(Set<Point16> goals) {
    final List<List<int>> matrix = makeEmptyMatrix(goals);
    bool wereChanges = true;

    while (wereChanges) {
      wereChanges = false;
      for (int y = 0; y < endY; y++) {
        for (int x = 0; x < endX; x++) {
          if (isPointPassable(Point16(x, y))) {
            int value = matrix[y][x];
            final neighbours = getNeighboringNodes(x, y);
            for (final _ in neighbours) {
              int lowestValueOfNeighbours =
                  getLowestValueOfNodes(matrix, neighbours);
              if (value - lowestValueOfNeighbours > 1) {
                matrix[y][x] = lowestValueOfNeighbours + 1;
                wereChanges = true;
              }
            }
          }
        }
      }
    }

    return matrix;
  }

  int getLowestValueOfNodes(List<List<int>> matrix, List<Point16> nodes) {
    int smallest = matrix[nodes[0].y][nodes[0].x];
    for (var node in nodes) {
      int value = matrix[node.y][node.x];
      if (value < smallest) smallest = value;
    }

    return smallest;
  }

  List<Point16> getNeighboringNodes(int x, int y) {
    List<Point16> neighbors = [];
    for (int yOffset = -1; yOffset <= 1; yOffset++) {
      for (int xOffset = -1; xOffset <= 1; xOffset++) {
        if (xOffset != 0 || yOffset != 0) {
          int neighborX = x + xOffset;
          int neighborY = y + yOffset;
          final point = Point16(neighborX, neighborY);
          if (pointFitsInMap(neighborX, neighborY) && isPointPassable(point)) {
            //robot.log("X: $neighborX Y: $neighborY");
            neighbors.add(Point16(neighborX, neighborY));
          }
        }
      }
    }

    return neighbors;
  }

  bool pointFitsInMap(int x, int y) => x >= 0 && y >= 0 && x < endX && y < endY;

  bool isPointPassable(Point16 point) => !impassablePoints.contains(point);
}
