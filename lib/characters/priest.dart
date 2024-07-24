import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'common.dart';

class PriestController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        GameCharacter<PriestAbraham>,
        PathFinding {
  PriestController(Vector2 position)
      : super(
          size: Vector2.all(16),
          position: position,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        ) {
    subscribeToGameState();
  }

  BehaviourFlag<PriestAbraham> prevBehaviour = const PriestAbrahamChilling();
  BehaviourFlag<PriestAbraham> currBehaviour = const PriestAbrahamChilling();

  @override
  bool transitioningToNewTurn = false;

  @override
  PriestAbraham get character => const PriestAbraham();

  @override
  void update(double dt) {
    if (GameState.$.isPaused) return;

    switch (currBehaviour) {
      case PriestAbrahamChilling():
        patrol(KeyLocation.church, dt);
    }
    super.update(dt);
  }

  @override
  void onStateChange(CharacterState newState) {
    if (newState.behaviour != currBehaviour) {
      prevBehaviour = currBehaviour;
      currBehaviour = newState.behaviour as BehaviourFlag<PriestAbraham>;
    }

    turnTransitionEnd();
  }

  @override
  void onMouseTap(MouseButton button) {
    if (button == MouseButton.left) CharacterTapManager.$.onTap(character);
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

