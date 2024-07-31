import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'animations.dart';

class FishermanController extends SimpleEnemy
    with
        BlockMovementCollision,
        SimpleMovement2,
        GameCharacter<Fisherman>,
        Attacker {
  FishermanController()
      : super(
          animation: Animations.fisherman,
          size: Vector2.all(24),
          position: KeyLocation.fishermanHut.tl.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        );

  bool allowedToKillPriest = false;

  @override
  BehaviourFlag<Fisherman> currBehaviour = const FishermanFishing();

  @override
  Fisherman get entityType => const Fisherman();

  @override
  Future<void> onLoad() {
    patrol(KeyLocation.fishermanHut.patrol);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead || gameState.isPaused) return;

    if (inAttackAnimation) {
      super.update(dt);
      return;
    }

    switch (currBehaviour) {
      case FishermanFishing():
      case FishermanHuntingPriest():
        final priest = characterTracker.priest;
        if (allowedToKillPriest && !priest.isDead && hasClearPathTo(priest)) {
          pausePatrolling(forceStop: true);
          final bool didAttack = tryAttack(
            priest,
            onFinish: () => speak("THAT'S FOR MY WIFE!",
                yell: true,
                onComplete: () => pausePatrolling(notifyFinish: true)),
          );

          if (!didAttack) moveTowardsTarget(target: priest);
        } else {
          resumePatrolling();
        }
    }
    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    super.onStateChange(newState);
    if (newState.behaviour == currBehaviour) return;
    currBehaviour = newState.behaviour as BehaviourFlag<Fisherman>;

    switch (currBehaviour) {
      case FishermanFishing():
        break;
      case FishermanHuntingPriest():
        await speak(
          "The love of my life got unfairly executed in "
          "the previous inquisition and I couldn't do anything...",
        );
        await speak(
          "I won't let a tragedy like that happen again!",
          yell: true,
        );
        allowedToKillPriest = true;
        await patrol(
          KeyLocation.massMurderPatrol
              .startFrom(const Point16(49, 25))
              .reversed
              .toList(),
          patrolSpeed: 1.2,
        );
    }
  }
}
