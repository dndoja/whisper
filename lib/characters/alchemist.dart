import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/movement.dart';

import 'common.dart';

class AlchemistController extends SimpleEnemy
    with
        BlockMovementCollision,
        SimpleMovement,
        MouseEventListener,
        GameCharacter<Alchemist>,
        PathFinding {
  AlchemistController()
      : super(
          size: Vector2.all(16),
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
          position: KeyLocation.alchemistLab.ref.mapPosition,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  @override
  BehaviourFlag<Alchemist> currBehaviour = const AlchemistIdle();

  @override
  Alchemist get entityType => const Alchemist();

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

    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    if (newState.behaviour == currBehaviour) return;
    currBehaviour = newState.behaviour as BehaviourFlag<Alchemist>;

    setupBlockMovementCollision(enabled: false);

    switch (currBehaviour) {
      case AlchemistIdle():
        break;
      case AlchemistTravelling(:final turnCount):
        final target = AlchemistTravelling.checkpoints[turnCount];
        await moveToTarget(target);
      case AlchemistPickingUpBones():
        await pathfindToPosition(KeyLocation.graveyard.tl.mapPosition);
        await showTextBubble('First off, let us get the bones');
      case AlchemistPickingUpHolyWater():
        final priest = characterTracker.priest;
        await moveToTarget(KeyLocation.church.ref);
        if (priest.getCurrentKeyLocation() != KeyLocation.church ||
            priest.isDead) {
          showTextBubble('Where is that scummy Priest?');
        } else {
          await showTextBubble(
            'Your Holyness, could you please lend me some Holy Water, '
            'one of my workers has a bad case of Posession.',
          );
          await priest.showTextBubble('Sure thing, here you go.');
        }

      case AlchemistPickingUpAstrologyTips():
        await pathfindToPosition(KeyLocation.observatory.ref.mapPosition);
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
