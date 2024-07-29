import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/movement.dart';

import 'common.dart';

enum AlchemistFailure {
  dead,
  noIngredients,
  badIngredients,
}

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

  int prevTravelCheckpoint = -1;
  bool experimentWillFail = false;

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
      // TODO: Play death animation, end game
      return;
    }

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
        for (int i = prevTravelCheckpoint + 1; i <= turnCount; i++) {
          final target = AlchemistTravelling.checkpoints[i];
          await moveToTarget(target);
        }
        prevTravelCheckpoint = turnCount;
      case AlchemistPickingUpBones():
        await pathfindToPosition(KeyLocation.graveyard.tl.mapPosition);
        await showTextBubble('First off, let us get the bones');
      case AlchemistPickingUpHolyWater():
        final priest = characterTracker.priest;
        await moveToTarget(KeyLocation.church.ref);
        if (priest.getCurrentKeyLocation() != KeyLocation.church ||
            priest.isDead) {
          await showTextBubble('Where is that damn Priest?');
          await failNoIngredient("The Priest's Holy Water");
        } else {
          await showTextBubble(
            'Your Holyness, could you please lend me some Holy Water, '
            'one of my workers has a bad case of Posession.',
          );
          await priest.showTextBubble('Sure thing, here you go.');
        }
      case AlchemistBuyingDefectiveHolyWater():
      case AlchemistBuyingOverpricedHolyWater():
        final priest = characterTracker.priest;
        await pathfindToPosition(const Point16(17, 14).mapPosition);
        if (priest.isDead) {
          await showTextBubble("Holy mother of God, what happened to you?");
          await failNoIngredient("Holy Water");
        } else {
          priest.pausePeriodicBubbles = true;
          await showTextBubble("Didn't take you for the entreprenurial type");
          await priest.showTextBubble(
            "Priesthood was not cutting it, anyhow, are you buying or just yapping?",
          );
          await showTextBubble("Yes, sorry. Can I have some Holy Water?");
          await priest.showTextBubble(
            "Sure here's some genuine Holy Alkaline Water, that'll be 10 gold.",
          );
          await showTextBubble("Kind of pricy but ok, here you go.");
          await priest.showTextBubble(
            "*hands over Holy Water* Pleasure doing business!",
          );
          priest.pausePeriodicBubbles = false;
          experimentWillFail = true;
        }
      case AlchemistPickingUpAstrologyTips():
        await pathfindToPosition(KeyLocation.observatory.ref.mapPosition);
      case AlchemistPerformingExperiment():
        await pathfindToPosition(KeyLocation.appleFarm.ref.mapPosition);
        if (experimentWillFail) {
          /// Fail catastrophically
        } else {
          /// Perform experiment successfully
        }
    }

    setupBlockMovementCollision(enabled: true);
  }

  Future<void> failNoIngredient(String ingredient) async {
    await showTextBubble(
      "I cannot perform this experiement without $ingredient. "
      "Guess I'll try again some other time...",
    );

    // show victory screen
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
