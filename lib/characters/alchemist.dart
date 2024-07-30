import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/decorations/ritual.dart';

import 'animations.dart';

enum AlchemistFailure {
  dead,
  noIngredients,
  badIngredients,
}

class AlchemistController extends SimpleEnemy
    with
        BlockMovementCollision,
        SimpleMovement2,
        MouseEventListener,
        GameCharacter<Alchemist>,
        PathFinding {
  AlchemistController()
      : super(
          animation: Animations.forCharacter(CharacterSheet.c, 3),
          size: Vector2.all(24),
          position: KeyLocation.alchemistLab.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  int prevTravelCheckpoint = -1;
  bool hasCorruptedHolyWater = false;

  @override
  BehaviourFlag<Alchemist> currBehaviour = const AlchemistIdle();

  @override
  Alchemist get entityType => const Alchemist();

  @override
  Future<void> onLoad() {
    gameRef.add(RitualDecorations.holyWater(KeyLocation.church.br.mapPosition));
    gameRef.add(RitualDecorations.holyWater(
      KeyLocation.church.tl.mapPosition,
      isCorrupted: true,
    ));
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
        final List<Point16> path = [
          for (int i = prevTravelCheckpoint + 1; i <= turnCount; i++)
            AlchemistTravelling.checkpoints[i],
        ];
        prevTravelCheckpoint = turnCount;
        await followPath(path);
      case AlchemistPickingUpBones():

        /// From village entrance to graveyard
        await followPath(const [
          Point16(22, 22),
          Point16(22, 3),
          Point16(22, 3),
          Point16(7, 3),
          Point16(7, 5),
        ]);
        await speak('First off, let us get the bones');
      case AlchemistPickingUpHolyWater():
        final priest = characterTracker.priest;
        await followPath(const [
          Point16(7, 3),
          Point16(22, 3),
          Point16(22, 14),
          Point16(31, 14),
        ]);
        if (priest.currentKeyLocation() != KeyLocation.church ||
            priest.isDead) {
          await speak('Where is that damn Priest?');
          await failNoIngredient("The Priest's Holy Water");
        } else {
          priest
            ..pausePatrolling()
            ..stopMove();

          await speak(
            'Your Holyness, could you please lend me some Holy Water, '
            'one of my workers has a bad case of Posession.',
          );
          await priest.speak('Sure thing, here you go.');
          priest.resumePatrolling();
        }
      case AlchemistBuyingDefectiveHolyWater():
      case AlchemistBuyingOverpricedHolyWater():
        final priest = characterTracker.priest;
        await followPath(const [
          Point16(7, 3),
          Point16(22, 3),
          Point16(22, 14),
          Point16(17, 14),
        ]);
        if (priest.isDead) {
          await speak("Holy mother of God, what happened to you?");
          await failNoIngredient("Holy Water");
        } else {
          priest.pausePeriodicBubbles = true;
          await speak("Didn't take you for the entreprenurial type");
          await priest.speak(
            "Priesthood was not cutting it, anyhow, are you buying or just yapping?",
          );
          await speak("Yes, sorry. Can I have some Holy Water?");
          await priest.speak(
            "Sure here's some genuine Holy Alkaline Water, that'll be 10 gold.",
          );
          await speak("Kind of pricy but ok, here you go.");
          await priest.speak(
            "*hands over Holy Water* Pleasure doing business!",
          );
          priest.pausePeriodicBubbles = false;
          hasCorruptedHolyWater = true;
        }
      case AlchemistPickingUpAstrologyTips():
        await followPath(const [
          Point16(42, 14),
          Point16(42, 10),
        ]);
        final astrologer = characterTracker.astrologer;
        bool failed = false;
        if (astrologer.isDead) {
          await speak(
            "Oh the horror! Who could have done something like this..",
            yell: true,
          );
          failed = true;
        } else if (astrologer.currentKeyLocation() != KeyLocation.observatory) {
          await speak(
            "How strange, that young Astrologer lady is always here at night... "
            "Maybe she's fallen ill, how unfortunate!",
          );
          failed = true;
        } else {
          astrologer
            ..pausePatrolling()
            ..stopMove();

          await speak('Studying late as always I see');
          await astrologer.speak("Proffessor Merlin! What brings you here?");
          await speak(
              "I need you to lend me a bit of your knowledge Maria, if you don't mind");
          await astrologer.speak('Sure thing, what is it you want to know?');
          await speak(
            'I need to find a place that gets hit perfectly'
            ' by Moonlight at exactly 23 minutes past midnight',
          );
          await astrologer
              .speak("Oh I thought you were going to ask me a hard question.");
          await astrologer.speak(
              "The place you're looking for is the Apple Farm, just east of here.");
          await astrologer.speak("Hurry though, you only have a few minutes");
          await speak(
              "You're a very talented young lady, many thanks. I'll be on my way.");
          astrologer.speak("You're most welcome Proffessor! Good Night");

          await followPath(const [Point16(42, 16)]);
        }

        if (failed) {
          await failNoIngredient(
            "knowing the location described in the scroll",
          );
        }
      case AlchemistPerformingExperiment():
        await followPath(const [Point16(66, 16), Point16(66, 10)]);

        for (final ritualElement in ritualDecorations) {
          if (ritualElement case RitualHolyWater(isCursed: final isCorrupted)) {
            if (hasCorruptedHolyWater != isCorrupted) continue;
          }

          ritualElement.isVisible = true;
          await Future.delayed(const Duration(milliseconds: 200));
        }

        final eclipseLight = RitualEclipseLight();
        gameRef.add(eclipseLight);
        speak('Here it comes!');
        await eclipseLight.onReachRitualSite;

        if (hasCorruptedHolyWater) {
          await speak("Huh, I don't feel so good...");
          replaceAnimation(Animations.undead);
          speak('Blegh');
          await patrol(KeyLocation.ritualSite.patrol);

          /// Fail catastrophically
        } else {
          await speak(
            "My joints don't hurt anymore... I AM UNSTOPPABLE!!!",
            yell: true,
          );

          /// Perform experiment successfully
        }
    }

    setupBlockMovementCollision(enabled: true);
  }

  Future<void> failNoIngredient(String ingredient) async {
    await speak(
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
