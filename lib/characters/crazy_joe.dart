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
        ChaseMovement {
  CrazyJoeController(Vector2 position)
      : super(
          size: Vector2.all(16),
          position: position,
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
      case CrazyJoeRunningFromUndead():
        if (!transitioningToNewTurn) {
          if (isVisibleInCamera()) {
            moveDown();
          }else if (!isRemoved){
            removeFromParent();
          }
        }
      case CrazyJoeLeavingVillage():
      case CrazyJoeRampaging():
      case CrazyJoeCrusading():
      case CrazyJoeSavingKingdom():
      case CrazyJoeFearingDevil():
      case CrazyJoeFindingGod():
      case CrazyJoeThinkingHeIsDead():
      case CrazyJoeFightingForPeace():
      case CrazyJoeStabbingPriest():
    }

    super.update(dt);
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
      case CrazyJoeRunningFromUndead():
        await pathfindToPosition(KeyLocation.villageExitSouth.br.mapPosition);
      case CrazyJoeDoomsaying():
        await pathfindToPosition(KeyLocation.villageMainSquare.ref.mapPosition);
      case CrazyJoeRepenting():
        await pathfindToPosition(KeyLocation.church.ref.mapPosition);
      case CrazyJoeStabbingPriest():
        final priest = characterTracker.priest;

        await pathfindToPosition(KeyLocation.church.ref.mapPosition);
        await chase(priest);

        if (distance(priest) <= 16) {
          showTextBubble('Die you piece of shit', onComplete: () {
            priest.removeLife(100);
            priest.playBloodAnimation();
          });
        }

        await pathfindToPosition(KeyLocation.crazyJoeFarm.ref.mapPosition);
        if (!isRemoved) removeFromParent();

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

  TextBubble? currTextBubble;
  double secondsElapsedSinceLastBubble = 0;
  bool showTextBubble(
    String text, {
    int? periodSeconds,
    double dt = 0,
    bool yell = false,
    void Function()? onComplete,
  }) {
    secondsElapsedSinceLastBubble += dt;
    if (periodSeconds != null &&
        secondsElapsedSinceLastBubble < periodSeconds) {
      return false;
    }

    if (currTextBubble != null && !currTextBubble!.isRemoved) {
      remove(currTextBubble!);
    }

    secondsElapsedSinceLastBubble = 0;
    currTextBubble = TextBubble(
      text,
      onComplete: onComplete,
      position: Vector2(8, -24),
      yell: yell,
    );
    add(currTextBubble!);
    return true;
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
