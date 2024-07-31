import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/decorations/ritual.dart';
import 'package:whisper/ui/ui.dart';

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
          animation: Animations.forCharacter(CharacterSheet.c, 3, 'alchemist'),
          size: Vector2.all(24),
          position: KeyLocation.alchemistLab.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        );

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
      UI.finishGame(GameOverResult.alchemistHarmed);
      return;
    }

    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    super.onStateChange(newState);
    if (newState.behaviour == currBehaviour) return;
    currBehaviour = newState.behaviour as BehaviourFlag<Alchemist>;

    setupBlockMovementCollision(enabled: false);

    switch (currBehaviour) {
      case AlchemistIdle():
        break;
      case AlchemistExplainingMasterPlan():
        final prefs = await SharedPreferences.getInstance();
        const key = 'w_alchemist_said_intro';
        final bool hasSpoken = prefs.getBool(key) ?? false;
        if (!hasSpoken) {
          await speak(
            'Tonight is a full moon, the perfect time to try out '
            'the ritual described in this ancient scroll.',
          );
          await speak("It supposedly makes you immortal...");
          await speak("According to the instructions, I'll need: ");
          await speak(
              "The ashes of a dead warrior. I can loot that from the village graveyard.");
          await speak(
              "Some Holy Water. I can just ask the Priest for a small amount.");
          await speak(
            "Lastly, I need to perform the ritual at exactly 23 "
            "minutes past midnight in a place that is \"Bathed by Moonlight\".",
          );
          await speak(
            "There's a young astrologer at the village who can maybe point me in the right direction.",
          );
          prefs.setBool(key, true);
        }

      await speak("Alright time to get going, I don't have a lot of time");
      case AlchemistTravelling(:final turnCount):
        final List<Point16> path = [
          for (int i = prevTravelCheckpoint + 1; i <= turnCount; i++)
            AlchemistTravelling.checkpoints[i],
        ];
        if (turnCount - prevTravelCheckpoint > 1) {
          speak("I must hurry, it's almost time for the ritual");
        }
        prevTravelCheckpoint = turnCount;
        await followPath(path, speed: 1.5);
      case AlchemistPickingUpBones():

        /// From village entrance to graveyard
        await followPath(const [
          Point16(22, 22),
          Point16(22, 3),
          Point16(22, 3),
          Point16(7, 3),
          Point16(7, 5),
        ]);
        await speak('First off, let me get the Ash for the kindling...');
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
            ..pausePeriodicBubbles = true
            ..stopMove();

          await speak(
            'Your Holyness, could you please lend me some Holy Water, '
            'one of my workers has a bad case of the Posessions.',
          );
          await priest.speak('Sure thing, here you go.');

          priest
            ..resumePatrolling()
            ..pausePeriodicBubbles = false;
        }
      case AlchemistBuyingDefectiveHolyWater():
        final canBuy = await startHolyWaterTransaction();
        if (canBuy) await buyFakeHolyWater();
      case AlchemistBuyingOverpricedHolyWater():
        final canBuy = await startHolyWaterTransaction();
        if (canBuy) await buyRealHolyWater();
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

          UI.finishGame(GameOverResult.alchemistHarmed);
        } else {
          await speak(
            "My joints don't hurt anymore... I AM UNSTOPPABLE!!!",
            yell: true,
          );

          UI.finishGame(GameOverResult.experimentSuccess);
        }
    }

    setupBlockMovementCollision(enabled: true);
  }

  Future<bool> startHolyWaterTransaction() async {
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
      return false;
    }

    priest.pausePeriodicBubbles = true;
    await speak("Didn't take you for the entreprenurial type your Holyness.");
    await priest.speak(
      "Priesthood was not cutting it, anyhow, are you buying or just yapping?",
    );
    await speak("Yes, sorry. Can I have some Holy Water?");

    return true;
  }

  Future<bool> buyFakeHolyWater() async {
    final priest = characterTracker.priest;

    await priest.speak(
      "Sure here's some genuine Holy Alkaline Water, that'll be 10 gold.",
    );
    await speak("That's suspiciously cheap but ok.");
    await priest.speak("*hands over Fake Holy Water*");
    priest.speak("Pleasure doing business with you! *ahem* dumbass");

    priest.pausePeriodicBubbles = false;
    hasCorruptedHolyWater = true;

    return true;
  }

  Future<bool> buyRealHolyWater() async {
    final priest = characterTracker.priest;

    await priest.speak(
      "Sure here's some plain Holy Water, that'll be 70 gold.",
    );
    await speak(
      "Holy Hell that's expensive, I have no choice though. Here you go.",
    );
    await priest.speak("*hands over Holy Water*");
    priest.speak("Pleasure doing business with you!");

    priest.pausePeriodicBubbles = false;

    return true;
  }

  Future<void> failNoIngredient(String ingredient) async {
    await speak(
      "I cannot perform this experiement without $ingredient. "
      "Guess I'll try again some other time...",
    );

    UI.finishGame(GameOverResult.interruptedExperiment);
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
