import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/utils.dart';

import 'core.dart';

class RobotPlayer {
  static List<Direction> directions = [];
  static Random random = Random();
}

mixin BugNav2 on SimpleEnemy {
  Direction? dir;
  Vector2? prevDest;
  Set<Vector2>? line;
  double obstacleStartDist = 0;

  int bugState = 0;
  Vector2? closestObstacle;
  int closestObstacleDist = 10000;
  Direction? bugDir;

  void resetBug() {
    bugState = 0;
    closestObstacle = null;
    closestObstacleDist = 10000;
    bugDir = null;
  }

  void bugNav(GameComponent target) {
    final destination = target.absoluteCenter;
    if (destination != prevDest) {
      prevDest = destination;
      line = createLine(absoluteCenter, destination);
    }

    if (bugState == 0) {
      bugDir = BonfireUtil.getDirectionFromAngle(getAngleFromTarget(target));
      if (canMove(bugDir!)) {
        moveFromDirection(bugDir!);
      } else {
        bugState = 1;
        obstacleStartDist = absoluteCenter.distanceTo(destination);
      }
    } else {
      if (line!.contains(absoluteCenter) &&
          absoluteCenter.distanceTo(destination) < obstacleStartDist) {
        bugState = 0;
      }

      for (int i = 0; i < 9; i++) {
        if (canMove(bugDir!)) {
          moveFromDirection(bugDir!);
          bugDir = bugDir!.rotateClockwise();
          bugDir = bugDir!.rotateClockwise();
          break;
        } else {
          bugDir = bugDir!.rotateCounterClockwise();
        }
      }
    }
  }

  Set<Vector2> createLine(Vector2 a, Vector2 b) {
    Set<Vector2> locs = {};
    double x = a.x, y = a.y;
    double dx = b.x - a.x;
    double dy = b.y - a.y;
    double sx = dx.sign;
    double sy = dy.sign;
    dx = dx.abs();
    dy = dy.abs();
    double d = max(dx, dy);
    double r = d / 2;
    if (dx > dy) {
      for (int i = 0; i < d; i++) {
        locs.add(Vector2(x, y));
        x += sx;
        r += dy;
        if (r >= dx) {
          locs.add(Vector2(x, y));
          y += sy;
          r -= dx;
        }
      }
    } else {
      for (int i = 0; i < d; i++) {
        locs.add(Vector2(x, y));
        y += sy;
        r += dx;
        if (r >= dy) {
          locs.add(Vector2(x, y));
          x += sx;
          r -= dy;
        }
      }
    }
    locs.add(Vector2(x, y));
    return locs;
  }
}
