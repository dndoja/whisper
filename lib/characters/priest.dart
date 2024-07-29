import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/movement.dart';

import 'common.dart';
import 'zombie.dart';

class PriestController extends SimpleEnemy
    with
        BlockMovementCollision,
        MouseEventListener,
        GameCharacter<Priest>,
        SimpleMovement2,
        PathFinding {
  PriestController()
      : super(
          size: Vector2.all(16),
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          position: KeyLocation.church.ref.mapPosition,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  @override
  BehaviourFlag<Priest> currBehaviour = const PriestPraying();

  @override
  Priest get entityType => const Priest();

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        anchor: Anchor.topLeft,
        position: Vector2(4, 4),
        radius: 4,
      ),
    );
    patrol(KeyLocation.church.patrol);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) {
      // TODO: Play death animation
      return;
    }

    if (gameState.isPaused) return;

    switch (currBehaviour) {
      case PriestScamming():
        if (!transitioningToNewTurn) {
          showTextBubble(
            "Totally real and working holy artifacts for sale, 50% off!",
            periodSeconds: 5,
            yell: true,
            dt: dt,
          );
        }
      case PriestPraying():
      case PriestSummoningZombies():
    }
    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    if (newState.behaviour == currBehaviour) return;

    currBehaviour = newState.behaviour as BehaviourFlag<Priest>;

    switch (currBehaviour) {
      case PriestSummoningZombies():
        await followPath(Paths.churchToGraveyard);
        await showTextBubble('*Chants in Latin*', yell: true);
        gameRef.addAll(List.generate(10, (_) => Undead()));
        gameRef.camera.follow(undeadCaptain);
        await undeadCaptain.massacreCompleter.future;
      case PriestScamming():
        await followPath(Paths.churchToMarket);
      default:
    }
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
