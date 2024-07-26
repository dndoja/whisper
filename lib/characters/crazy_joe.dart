import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
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
      // return;
    }

    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    if (newState.behaviour == currBehaviour) return;

    prevBehaviour = currBehaviour;
    currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

    switch (currBehaviour) {
      case CrazyJoeRampaging():
      // await pathfindToPosition(const Point16(50, 50).mapPosition);
      case CrazyJoeStabbingPriest():
        final priest = characterTracker.priest;

        setupBlockMovementCollision(enabled: false);

        await pathfindToPosition(KeyLocation.church.ref.mapPosition);
        await chase(priest);

        if (distance(priest) <= 16) {
          priest.removeLife(100);
          showDamage(100);
        }

        await pathfindToPosition(KeyLocation.crazyJoeFarm.ref.mapPosition);

        setupBlockMovementCollision(enabled: true);

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
