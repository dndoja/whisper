import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'common.dart';

class FishermanController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        GameCharacter<Fisherman>,
        PathFinding {
  FishermanController()
      : super(
          size: Vector2.all(16),
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          position: KeyLocation.fishermanHut.tl.mapPosition,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  BehaviourFlag<Fisherman> prevBehaviour = const FishermanFishing();
  BehaviourFlag<Fisherman> currBehaviour = const FishermanFishing();

  @override
  Fisherman get entityType => const Fisherman();

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
      case FishermanFishing():
        patrol(KeyLocation.fishermanHut, dt);
    }
    super.update(dt);
  }

  @override
  void onStateChange(CharacterState newState) {
    if (newState.behaviour != currBehaviour) {
      prevBehaviour = currBehaviour;
      currBehaviour = newState.behaviour as BehaviourFlag<Fisherman>;
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
