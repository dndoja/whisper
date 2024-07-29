import 'dart:async';
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';

import 'animations.dart';

class UndeadConfig {
  const UndeadConfig({
    required this.spawn,
    required this.initialPath,
    required this.patrol,
  });

  final Point16 spawn;
  final List<Point16> initialPath;
  final List<Point16> patrol;
}

const List<UndeadConfig> configs = [
  UndeadConfig(
    spawn: Point16(15, 1),
    initialPath: [
      Point16(22, 3),
      Point16(22, 14),
      Point16(42, 14),
      Point16(42, 11),
      Point16(42, 25),
    ],
    patrol: [Point16(55, 25), Point16(42, 25)],
  ),
  // UndeadConfig(
  //   spawn: Point16(7, 1),
  //   initialPath: [Point16(20, 2)],
  //   patrol: [
  //     Point16(20, 12),
  //     Point16(20, 22),
  //     Point16(25, 22),
  //     Point16(25, 15)
  //   ],
  // ),
  // UndeadConfig(
  //   spawn: Point16(9, 1),
  //   initialPath: [Point16(22, 15)],
  //   patrol: [
  //     Point16(27, 15),
  //     Point16(35, 15),
  //     Point16(35, 21),
  //     Point16(27, 21)
  //   ],
  // ),
  // UndeadConfig(
  //   spawn: Point16(11, 1),
  //   initialPath: [Point16(38, 3), Point16(38, 10)],
  //   patrol: [
  //     Point16(41, 10),
  //     Point16(41, 8),
  //     Point16(44, 8),
  //     Point16(44, 11),
  //     Point16(41, 11),
  //   ],
  // ),
  // UndeadConfig(
  //   spawn: Point16(13, 1),
  //   initialPath: [
  //     Point16(22, 3),
  //     Point16(22, 16),
  //     Point16(42, 15),
  //     Point16(42, 25),
  //   ],
  //   patrol: [Point16(55, 25), Point16(42, 25)],
  // ),
];

int _spawnIndex = 0;
int get spawnIndex {
  final curr = _spawnIndex;
  if (_spawnIndex + 1 == configs.length) {
    _spawnIndex = 0;
  } else {
    _spawnIndex++;
  }

  return curr;
}

Undead? _undeadCaptain;
Undead get undeadCaptain => _undeadCaptain!;

class Undead extends SimpleEnemy with BlockMovementCollision, SimpleMovement2 {
  Undead()
      : config = configs[spawnIndex],
        super(
          size: Vector2.all(24),
          position: Vector2.zero(),
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
          animation: Animations.forCharacter(CharacterSheet.monsters, 0),
        ) {
    if (config == configs.first) _undeadCaptain ??= this;
  }

  final UndeadConfig config;
  final Completer massacreCompleter = Completer();

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        anchor: Anchor.center,
        position: Vector2(12, 16),
        radius: 4,
      ),
    );
    position = config.spawn.mapPosition + spawnOffset;
    followPath(config.initialPath).then((_) =>
        patrol(config.patrol, patrolSpeed: 1)
            .then((_) => massacreCompleter.complete()));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameState.isPaused) return;

    final nearbyVictim = nearbyCharacters().firstOrNull;
    if (nearbyVictim != null && hasClearPathTo(nearbyVictim)) {
      // chaseTarget(nearbyVictim, onFinish: () => tryAttack(nearbyVictim));
      pausePatrolling();
      final bool attacked = tryAttack(nearbyVictim);
      if (!attacked) moveTowardsTarget(target: nearbyVictim);
    } else {
      resumePatrolling();
    }
    // doMassMurder();

    super.update(dt);
  }

  final Set<KeyLocation> visitedKeyLocs = {};
  final KeyLocationComponent nextMassMurderLoc = KeyLocationComponent();
  List<Vector2>? pathToMassMurderLoc;

  // void doMassMurder() {
  //   final nearbyVictim = nearbyCharacters().firstOrNull;
  //
  //   final KeyLocation? currKeyLoc = getCurrentKeyLocation();
  //   if (currKeyLoc != null) visitedKeyLocs.add(currKeyLoc);
  //
  //   if (nearbyVictim != null) {
  //     final bool attacked = tryAttack(nearbyVictim);
  //     if (!attacked) bugPathTo(nearbyVictim);
  //   } else {
  //     if (visitedKeyLocs.containsAll(KeyLocation.massMurderLocations)) {
  //       visitedKeyLocs.clear();
  //     }
  //
  //     final KeyLocation? nextKeyLoc = nextMassMurderLoc.keyLocation;
  //
  //     if (nextKeyLoc == null || currKeyLoc == nextKeyLoc) {
  //       final validLocs = KeyLocation.massMurderLocations
  //           .where((l) => l != currKeyLoc && !visitedKeyLocs.contains(l))
  //           .toList();
  //       nextMassMurderLoc.keyLocation =
  //           validLocs[math.Random().nextInt(validLocs.length)];
  //     }
  //
  //     if (nextMassMurderLoc.keyLocation != null) bugPathTo(nextMassMurderLoc);
  //   }
  // }
}
