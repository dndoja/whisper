import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/chase.dart';
import 'package:whisper/core/utils.dart';

import 'common.dart';

class CrazyJoeController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        GameCharacter<CrazyJoe>,
        PathFinding,
        ChaseMovement,
        BugNav {
  CrazyJoeController()
      : super(
          size: Vector2.all(16),
          position: KeyLocation.crazyJoeFarm.ref.mapPosition,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        ) {
    subscribeToGameState();
  }

  BehaviourFlag<CrazyJoe> prevBehaviour = const CrazyJoeChilling();
  BehaviourFlag<CrazyJoe> currBehaviour = const CrazyJoeChilling();

  @override
  CrazyJoe get entityType => const CrazyJoe();

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

    if (transitioningToNewTurn) {
      super.update(dt);
      return;
    }

    switch (currBehaviour) {
      case CrazyJoeChilling():
        patrol(KeyLocation.crazyJoeFarm, dt);
      case CrazyJoeDoomsaying():
        patrol(KeyLocation.villageMainSquare, dt);
        showTextBubble(
          'DEATH IS COMING!',
          dt: dt,
          periodSeconds: 10,
          yell: true,
        );
      case CrazyJoeRepenting():
        showTextBubble(
          'I must repent... *whips himself*',
          dt: dt,
          periodSeconds: 10,
          onComplete: () => playBloodAnimation(maxForce: 200, count: 50),
        );
      case CrazyJoeRunningFromZombies():
      case CrazyJoeRunningFromGhosts():
      case CrazyJoeSavingKingdom():
      case CrazyJoeFightingForPeace():
      case CrazyJoeFindingGod():
        if (isVisibleInCamera()) {
          moveDown();
        } else if (!isRemoved) {
          removeFromParent();
        }
      case CrazyJoeRampaging():
      case CrazyJoeCrusading():
        doMassMurder();
      case CrazyJoeFearingDevil():
      case CrazyJoeThinkingHeIsDead():
      case CrazyJoeStabbingPriest():
    }

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
        final currPoint = Point16.fromMapPos(absoluteCenter);

        nextMassMurderLoc.keyLocation = KeyLocation.massMurderLocations
            .where((l) => l != currKeyLoc && !visitedKeyLocs.contains(l))
            .minBy((l) => l.ref.distanceSquaredTo(currPoint));
      }

      if (nextMassMurderLoc.keyLocation != null) bugPathTo(nextMassMurderLoc);
    }
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    final dialog = gameState
        .characterDialogs()
        .firstOrNullWhere((d) => d.$1 == entityType);
    if (dialog != null) showTextBubble(dialog.$2);

    if (newState.behaviour == currBehaviour) return;

    prevBehaviour = currBehaviour;
    currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

    setupBlockMovementCollision(enabled: false);

    switch (currBehaviour) {
      case CrazyJoeCrusading():
        await pathfindToPosition(KeyLocation.villageEntrance.ref.mapPosition);
      case CrazyJoeRunningFromZombies():
        await pathfindToPosition(KeyLocation.villageExitSouth.br.mapPosition);
      case CrazyJoeDoomsaying():
        await pathfindToPosition(KeyLocation.villageMainSquare.ref.mapPosition);
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

    setupBlockMovementCollision(enabled: true);
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
