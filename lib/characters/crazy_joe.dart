import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';

import 'common.dart';

class CrazyJoeController extends SimpleEnemy
    with
        BlockMovementCollision,
        RandomMovement,
        MouseEventListener,
        GameCharacter<CrazyJoe>,
        PathFinding {
  CrazyJoeController(Vector2 position)
      : super(
          size: Vector2.all(16),
          position: position,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        ) {
    subscribeToGameState();
  }

  BehaviourFlag<CrazyJoe> prevBehaviour = const CrazyJoeChilling();
  BehaviourFlag<CrazyJoe> currBehaviour = const CrazyJoeChilling();

  @override
  bool transitioningToNewTurn = false;

  @override
  CrazyJoe get character => const CrazyJoe();

  @override
  void update(double dt) {
    if (GameState.$.isPaused) return;

    switch (currBehaviour) {
      case CrazyJoeChilling():
        patrol(KeyLocation.crazyJoeFarm, dt);
      case CrazyJoeRampaging():
      case CrazyJoeCrusading():
      case CrazyJoeSavingKingdom():
      case CrazyJoeFearingDevil():
      case CrazyJoeFindingGod():
      case CrazyJoeThinkingHeIsDead():
      case CrazyJoeLeavingVillage():
      case CrazyJoeFightingForPeace():
      case CrazyJoeStabbingPriest():
      case CrazyJoeRunningFromUndead():
      case CrazyJoeAtoneing():
        // throw UnimplementedError();
    }
    super.update(dt);
  }

  @override
  void onStateChange(CharacterState newState) {
    if (newState.behaviour != currBehaviour) {
      prevBehaviour = currBehaviour;
      currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

      turnTransitionStart();
      switch (currBehaviour) {
        case CrazyJoeRampaging():
          gameRef.camera.follow(this);
          moveToPositionWithPathFinding(
            const Point16(50, 50).mapPosition,
            onFinish: turnTransitionEnd,
          );
        default:
          turnTransitionEnd();
      }
    } else {
      turnTransitionEnd();
    }
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
