import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'animations.dart';

class AstrologerController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        SimpleMovement2,
        GameCharacter<Astrologer> {
  AstrologerController()
      : super(
          animation: Animations.forCharacter(CharacterSheet.a, 5, 'astrologer'),
          size: Vector2.all(24),
          position: KeyLocation.observatory.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  @override
  BehaviourFlag<Astrologer> currBehaviour = const AstrologerObserving();

  @override
  Astrologer get entityType => const Astrologer();

  @override
  Future<void> onLoad() {
    patrol(KeyLocation.observatory.patrol, patrolSpeed: 0.1);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) {
      // TODO: Play death animation
      return;
    }

    if (gameState.isPaused) return;

    super.update(dt);
  }

  @override
  void onStateChange(CharacterState newState) {
    super.onStateChange(newState);
    if (newState.behaviour != currBehaviour) {
      currBehaviour = newState.behaviour as BehaviourFlag<Astrologer>;
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
