import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/movement.dart';

import 'animations.dart';
import 'undead.dart';

class PriestController extends SimpleEnemy
    with
        BlockMovementCollision,
        MouseEventListener,
        SimpleMovement2,
        GameCharacter<Priest>,
        PathFinding {
  PriestController()
      : super(
          animation: Animations.forCharacter(CharacterSheet.c, 2, 'priest'),
          size: Vector2.all(24),
          position: KeyLocation.church.ref.mapPosition + spawnOffset,
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
    patrol(KeyLocation.church.patrol);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // die();

    // if (playingDeathAnimation) {
    //   super.update(dt);
    //   return;
    // }

    if (gameState.isPaused) return;

    switch (currBehaviour) {
      case PriestScamming():
        if (!transitioningToNewTurn) {
          speak(
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
    super.onStateChange(newState);
    if (newState.behaviour == currBehaviour) return;

    currBehaviour = newState.behaviour as BehaviourFlag<Priest>;

    switch (currBehaviour) {
      case PriestSummoningZombies():
        await followPath(Paths.churchToGraveyard);
        await speak('*Chants in Latin*', yell: true);
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
