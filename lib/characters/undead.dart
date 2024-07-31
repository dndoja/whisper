import 'dart:async';
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';

import 'animations.dart';

class UndeadConfig {
  const UndeadConfig({
    required this.spawn,
    this.initialPath = const [],
    this.patrol,
  });

  final Point16 spawn;
  final List<Point16> initialPath;
  final List<Point16>? patrol;
}

final List<UndeadConfig> configs = [
  UndeadConfig(
    spawn: const Point16(15, 1),
    initialPath: [
      const Point16(22, 3),
      const Point16(22, 14),
    ],
    patrol: KeyLocation.massMurderPatrol.startFrom(const Point16(26, 14)),
  ),
  const UndeadConfig(spawn: Point16(7, 1)),
  const UndeadConfig(spawn: Point16(9, 1)),
  const UndeadConfig(spawn: Point16(11, 1)),
  const UndeadConfig(spawn: Point16(13, 1)),
  const UndeadConfig(spawn: Point16(7, 5)),
  const UndeadConfig(spawn: Point16(9, 5)),
  const UndeadConfig(spawn: Point16(11, 5)),
  const UndeadConfig(spawn: Point16(13, 5)),
];

int _spawnIndex = 0;
int get spawnIndex {
  final curr = _spawnIndex;
  if (_spawnIndex + 1 == configs.length) {
    _spawnIndex = 1;
  } else {
    _spawnIndex++;
  }

  return curr;
}

Undead? _undeadCaptain;
Undead get undeadCaptain => _undeadCaptain!;

class Undead extends SimpleEnemy
    with BlockMovementCollision, SimpleMovement2, RandomMovement, Attacker {
  Undead()
      : config = configs[spawnIndex],
        super(
          size: Vector2.all(24),
          position: Vector2.zero(),
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
          animation: Animations.undead,
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
    if (this == _undeadCaptain) {
      followPath(config.initialPath).then((_) =>
          patrol(config.patrol ?? KeyLocation.massMurderPatrol, patrolSpeed: 1)
              .then((_) => massacreCompleter.complete()));
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameState.isPaused) return;

    if (inAttackAnimation) {
      super.update(dt);
      return;
    }

    final nearbyVictim = nearbyCharacters().firstOrNull;

    if (this != _undeadCaptain) {
      final bool attacked = nearbyVictim != null && tryAttack(nearbyVictim);
      if (!attacked) runRandomMovement(dt);
      super.update(dt);
      return;
    }

    if (nearbyVictim != null && hasClearPathTo(nearbyVictim)) {
      pausePatrolling();
      final bool attacked = tryAttack(nearbyVictim);
      if (!attacked) moveTowardsTarget(target: nearbyVictim);
    } else {
      resumePatrolling();
    }

    super.update(dt);
  }
}
