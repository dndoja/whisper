import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'animations.dart';

class FishermanController extends SimpleEnemy
    with
        BlockMovementCollision,
        SimpleMovement2,
        MouseEventListener,
        GameCharacter<Fisherman>,
        PathFinding {
  FishermanController()
      : super(
          animation: Animations.forCharacter(CharacterSheet.c, 5, 'fisherman'),
          size: Vector2.all(24),
          position: KeyLocation.fishermanHut.tl.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

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
    if (isDead) {
      // TODO: Play death animation
      return;
    }

    if (gameState.isPaused) return;

    switch (currBehaviour) {
      case FishermanFishing():
    }
    super.update(dt);
  }

  @override
  void onStateChange(CharacterState newState) {
    super.onStateChange(newState);
    if (newState.behaviour != currBehaviour) {
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
