import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'common.dart';
import 'zombie.dart';

class PriestController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        GameCharacter<Priest>,
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

  BehaviourFlag<Priest> prevBehaviour = const PriestPraying();
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
      case PriestPraying():
        patrol(KeyLocation.church, dt);
      case PriestSummoningZombies():
    }
    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    if (newState.behaviour == currBehaviour) return;

    prevBehaviour = currBehaviour;
    currBehaviour = newState.behaviour as BehaviourFlag<Priest>;

    switch (currBehaviour) {
      case PriestSummoningZombies():
        await pathfindToPosition(KeyLocation.graveyard.ref.mapPosition);
        await showTextBubble('*Chants in Latin*', yell: true);
        gameRef.addAll(List.generate(10, (_) => Undead()));
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
