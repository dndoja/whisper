import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/chase.dart';
import 'package:whisper/core/utils.dart';

import 'common.dart';

const List<Point16> spawns = [
  Point16(7, 1),
  Point16(9, 1),
  Point16(11, 1),
  Point16(13, 1),
  Point16(15, 1),
  Point16(7, 5),
  Point16(9, 5),
  Point16(11, 5),
  Point16(13, 5),
  Point16(15, 5),
];

int _spawnIndex = 0;
int get spawnIndex {
  final curr = _spawnIndex;
  if (_spawnIndex + 1 == spawns.length) {
    _spawnIndex = 0;
  } else {
    _spawnIndex++;
  }

  return curr;
}

class Undead extends SimpleEnemy
    with BlockMovementCollision, PathFinding, BugNav {
  Undead()
      : super(
          size: Vector2.all(16),
          position: spawns[spawnIndex].mapPosition,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        );

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        anchor: Anchor.topLeft,
        position: Vector2(4, 4),
        radius: 4,
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameState.isPaused) return;

    doMassMurder();

    super.update(dt);
  }

  final Set<KeyLocation> visitedKeyLocs = {};
  final KeyLocationComponent nextMassMurderLoc = KeyLocationComponent();
  List<Vector2>? pathToMassMurderLoc;

  void doMassMurder() {
    final nearbyVictim = nearbyCharacters().firstOrNull;

    final KeyLocation? currKeyLoc = getCurrentKeyLocation();
    if (currKeyLoc != null) visitedKeyLocs.add(currKeyLoc);

    if (nearbyVictim != null) {
      final bool attacked = tryAttack(nearbyVictim);
      if (!attacked) bugPathTo(nearbyVictim);
    } else {
      if (visitedKeyLocs.containsAll(KeyLocation.massMurderLocations)) {
        visitedKeyLocs.clear();
      }

      final KeyLocation? nextKeyLoc = nextMassMurderLoc.keyLocation;

      if (nextKeyLoc == null || currKeyLoc == nextKeyLoc) {
        final validLocs = KeyLocation.massMurderLocations
            .where((l) => l != currKeyLoc && !visitedKeyLocs.contains(l))
            .toList();
        nextMassMurderLoc.keyLocation =
            validLocs[math.Random().nextInt(validLocs.length)];
      }

      if (nextMassMurderLoc.keyLocation != null) bugPathTo(nextMassMurderLoc);
    }
  }
}
