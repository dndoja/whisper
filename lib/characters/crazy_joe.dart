import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/chase.dart';

import 'animations.dart';

class CrazyJoeController extends SimpleEnemy
    with
        RandomMovement,
        MouseEventListener,
        SimpleMovement2,
        GameCharacter<CrazyJoe>,
        PathFinding,
        ChaseMovement,
        BugNav {
  CrazyJoeController()
      : super(
          // animation: Animations.forCharacter(CharacterSheet.b, 1),
          animation: Animations.knight,
          size: Vector2.all(24),
          position: KeyLocation.crazyJoeFarm.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  @override
  BehaviourFlag<CrazyJoe> currBehaviour = const CrazyJoeChilling();

  @override
  CrazyJoe get entityType => const CrazyJoe();

  @override
  Future<void> onLoad() {
    patrol(KeyLocation.crazyJoeFarm.patrol);
    return super.onLoad();
  }

  bool inAttackAnimation = false;

  @override
  void update(double dt) {
    if (gameState.isPaused) return;

    if (inAttackAnimation) {
      super.update(dt);
      return;
    }

    switch (currBehaviour) {
      case CrazyJoeChilling():
        break;
      case CrazyJoeDoomsaying():
        if (!transitioningToNewTurn) {
          showTextBubble(
            'DEATH IS COMING!',
            dt: dt,
            periodSeconds: 10,
            yell: true,
          );
        }
      case CrazyJoeRepenting():
        if (!transitioningToNewTurn) {
          showTextBubble(
            'I must repent... *whips himself*',
            dt: dt,
            periodSeconds: 10,
            onComplete: () => playBloodAnimation(maxForce: 200, count: 50),
          );
        }
      case CrazyJoeRunningFromZombies():
      case CrazyJoeRunningFromGhosts():
      case CrazyJoeSavingKingdom():
      case CrazyJoeFightingForPeace():
      case CrazyJoeFindingGod():
        if (!transitioningToNewTurn) {
          if (isVisibleInCamera()) {
            moveDown();
          } else if (!isRemoved) {
            removeFromParent();
          }
        }
      case CrazyJoeRampaging():
      case CrazyJoeCrusading():
        final nearbyVictim = nearbyCharacters().firstOrNull;
        if (nearbyVictim != null && hasClearPathTo(nearbyVictim)) {
          pausePatrolling();

          // chaseTarget(nearbyVictim, onFinish: () => tryAttack(nearbyVictim));
          if (isInAttackRange(nearbyVictim)) {
            stopMove();
            nearbyVictim
              ..pausePatrolling()
              ..stopMove();
            inAttackAnimation = true;
            animation?.playOnceOther(
              AttackAnimation.fromAngle(getAngleFromTarget(nearbyVictim)),
              onFinish: () {
                inAttackAnimation = false;
                nearbyVictim
                  ..removeLife(nearbyVictim.maxLife)
                  ..playBloodAnimation();
              },
            );
          } else {
            moveTowardsTarget(target: nearbyVictim);
          }
        } else {
          resumePatrolling();
        }
      case CrazyJoeFearingDevil():
      case CrazyJoeThinkingHeIsDead():
      case CrazyJoeStabbingPriest():
    }

    super.update(dt);
  }

  final Set<KeyLocation> visitedKeyLocs = {};
  final KeyLocationComponent nextMassMurderLoc = KeyLocationComponent();
  List<Vector2>? pathToMassMurderLoc;

  @override
  Future<void> onStateChange(CharacterState newState) async {
    final dialog = gameState
        .characterDialogs()
        .firstOrNullWhere((d) => d.$1 == entityType);
    if (dialog != null) showTextBubble(dialog.$2);

    if (newState.behaviour == currBehaviour) return;

    currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

    // setupBlockMovementCollision(enabled: false);

    switch (currBehaviour) {
      case CrazyJoeCrusading():
        // replaceAnimation(Animations.knight);
        await followPath(KeyLocation.villageEntrancePath);
        await patrol(KeyLocation.massMurderPatrol, patrolSpeed: 1);
      case CrazyJoeRunningFromZombies():
        await pathfindToPosition(KeyLocation.villageExitSouth.br.mapPosition);
      case CrazyJoeDoomsaying():
        await followPath(KeyLocation.villageEntrancePath);
        patrol(KeyLocation.villageMainSquare.patrol);
      case CrazyJoeRepenting():
        await pathfindToPosition(KeyLocation.church.ref.mapPosition);
      case CrazyJoeStabbingPriest():
        final priest = characterTracker.priest;

        await pathfindToPosition(KeyLocation.church.ref.mapPosition);
        await chase(priest);

        if (isInAttackRange(priest)) {
          showTextBubble('Die you piece of shit');
          priest.removeLife(100);
          priest.playBloodAnimation();
        }

        await pathfindToPosition(KeyLocation.crazyJoeFarm.ref.mapPosition);

      default:
    }

    // setupBlockMovementCollision(enabled: true);
  }

  @override
  void onMouseTap(MouseButton button) {
    if (button == MouseButton.left) CharacterTapManager.$.onTap(entityType);
  }

  @override
  void onMouseHoverEnter(int pointer, Vector2 position) {
    if (CharacterTapManager.$.waitingForTaps) {
      (gameRef as BonfireGame).mouseCursor = SystemMouseCursors.click;
    }
  }

  @override
  void onMouseHoverExit(int pointer, Vector2 position) {
    (gameRef as BonfireGame).mouseCursor = MouseCursor.defer;
  }
}

extension BloodAnimation on SimpleEnemy {
  static final rng = math.Random();
  static final startPos = Vector2.all(8);

  void playBloodAnimation({
    Duration? delay,
    int count = 200,
    int maxForce = 500,
  }) =>
      add(
        ParticleSystemComponent(
          position: startPos,
          particle: Particle.generate(
            count: count,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(
                randBetween(-maxForce, maxForce),
                randBetween(-maxForce, maxForce),
              ),
              child: CircleParticle(
                paint: Paint()..color = Colors.red,
                radius: rng.nextDouble() * 2,
              ),
            ),
          ),
        ),
      );

  double randBetween(int min, int max) =>
      (rng.nextInt(max - min) + min).toDouble();
}
