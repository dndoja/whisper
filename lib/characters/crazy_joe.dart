import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/chase.dart';

import 'animations.dart';

const prayer = "Oh Heavenly Father please forgive me for my sinful desires!";

class CrazyJoeController extends SimpleEnemy
    with
        RandomMovement,
        MouseEventListener,
        SimpleMovement2,
        GameCharacter<CrazyJoe>,
        PathFinding,
        Attacker,
        ChaseMovement,
        BugNav {
  CrazyJoeController()
      : super(
          animation: Animations.crazyJoe,
          size: Vector2.all(24),
          position: KeyLocation.crazyJoeFarm.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        ) {
    subscribeToGameState();
  }

  @override
  BehaviourFlag<CrazyJoe> currBehaviour = const CrazyJoeChilling();

  @override
  CrazyJoe get entityType => const CrazyJoe();

  @override
  Future<void> onLoad() {
    patrol(KeyLocation.crazyJoeFarm.patrol);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameState.isPaused) return;

    if (inAttackAnimation) {
      super.update(dt);
      return;
    }

    switch (currBehaviour) {
      case CrazyJoeChilling():
        break;
      case CrazyJoeDoomsaying():
        if (!transitioningToNewTurn) {
          speak(
            'DEATH IS COMING!',
            dt: dt,
            periodSeconds: 10,
            yell: true,
          );
        }
      case CrazyJoeRepenting():
        if (!transitioningToNewTurn) {
          speak(
            'I MUST REPENT!',
            dt: dt,
            periodSeconds: 10,
            onComplete: () {
              speak('*whips himself*', yell: true);
              playBloodAnimation(maxForce: 200, count: 50);
            },
            yell: true,
          );
        }
      case CrazyJoeRunningFromZombies():
      case CrazyJoeRunningFromGhosts():
      case CrazyJoeSavingKingdom():
      case CrazyJoeFightingForPeace():
      case CrazyJoeFindingGod():
        if (!transitioningToNewTurn) {
          if (isVisibleInCamera()) {
            moveDown();
          } else if (!isRemoved) {
            removeFromParent();
          }
        }
      case CrazyJoeRampaging():
      case CrazyJoeCrusading():
        final nearbyVictim = nearbyCharacters().firstOrNull;
        if (nearbyVictim != null && hasClearPathTo(nearbyVictim)) {
          pausePatrolling(forceStop: true);
          final bool didAttack = tryAttack(nearbyVictim);
          if (!didAttack) moveTowardsTarget(target: nearbyVictim);
        } else {
          resumePatrolling();
        }
      case CrazyJoeFearingDevil():
        if (!transitioningToNewTurn) speak(prayer, periodSeconds: 10, dt: dt);
      case CrazyJoeThinkingHeIsDead():
      case CrazyJoeStabbingPriest():
        final priest = characterTracker.priest;
        if (!priest.isDead && hasClearPathTo(priest)) {
          pausePatrolling(forceStop: true);
          final bool didAttack = tryAttack(
            priest,
            onFinish: () => speak(
              'GO TRY NECROMANCY ON YOURSELF NOW YOU PIECE OF SHIT!',
              yell: true,
            ),
          );

          if (!didAttack) moveTowardsTarget(target: priest);
        } else {
          resumePatrolling();
        }
    }

    super.update(dt);
  }

  final Set<KeyLocation> visitedKeyLocs = {};
  final KeyLocationComponent nextMassMurderLoc = KeyLocationComponent();
  List<Vector2>? pathToMassMurderLoc;

  @override
  Future<void> onStateChange(CharacterState newState) async {
    super.onStateChange(newState);
    final dialog = gameState
        .characterDialogs()
        .firstOrNullWhere((d) => d.$1 == entityType);
    if (dialog != null) speak(dialog.$2);

    if (newState.behaviour == currBehaviour) return;

    currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

    switch (currBehaviour) {
      case CrazyJoeChilling():
        break;
      case CrazyJoeCrusading():
        await crusading();
      case CrazyJoeSavingKingdom():
        await savingKingdom();
      case CrazyJoeFindingGod():
        await findingGod();
      case CrazyJoeFearingDevil():
        await fearingDevil();
      case CrazyJoeRampaging():
        await rampaging();
      case CrazyJoeThinkingHeIsDead():
        await thinkingHesDead();
      case CrazyJoeRunningFromGhosts():
        await runningFromGhosts();
      case CrazyJoeFightingForPeace():
        await fightingForPeace();
      case CrazyJoeStabbingPriest():
        await stabbingPriest();
      case CrazyJoeDoomsaying():
        await doomsaying();
      case CrazyJoeRepenting():
        await repenting();
      case CrazyJoeRunningFromZombies():
        await runningFromUndead();
    }
  }

  Future<void> putOnArmor({bool announce = true}) async {
    if (announce) await speak('I must fetch my armor...');
    await followPath2([(13, 51), (13, 47)], speed: 0.3);
    isVisible = false;
    await Future.delayed(const Duration(milliseconds: 200));
    replaceAnimation(Animations.knight);
    animationPrefix = 'knight';
    isVisible = true;
    await followPath2([(13, 51)]);
  }

  Future<void> crusading() async {
    await putOnArmor();
    speak(
      "Those infidels in the village will bring ruin upon this land. "
      "God Willing, I will save us!",
    );
    await followPath(KeyLocation.villageEntrancePath);
    await patrol(KeyLocation.massMurderPatrol, patrolSpeed: 1);
  }

  Future<void> savingKingdom() async {
    await putOnArmor();
    speak('God has spoken to me, I must go save this kingdom. Deus Vult!');
    await followPath2([(31, 51), (31, 59)]);
  }

  Future<void> fearingDevil() async {
    await speak("God would never speak to someone like me, I'm not worthy.");
    await speak("It must have been the Devil!", yell: true);
    speak("I must pray...");
    await followPath(KeyLocation.villageEntrancePath);
    await followPath2([(26, 21), (26, 15), (31, 13)]);
    await speak(prayer);
  }

  Future<void> findingGod() async {
    speak(
      'God has spoken to me. I am his disciple... I must go on a pilgrimage.',
    );
    await followPath2([(31, 51), (31, 59)]);
  }

  Future<void> rampaging() async {
    await speak(
      'I remember now, everyone was murdered on that attack 2 years ago...',
    );
    await speak(
      'But then, if everyone is dead... Then who are those people in the village?',
    );
    await speak('THEY MUST BE DEMONS TRYING TO TAKE MY LAND!', yell: true);
    speak('THIS IS MY PROPERTY. I WILL STAND MY GROUND! YOU HEAR ME?!',
        yell: true);
    await followPath(KeyLocation.villageEntrancePath);
    await patrol(KeyLocation.massMurderPatrol, patrolSpeed: 1);
  }

  Future<void> thinkingHesDead() async {
    await speak(
      'I remember now, everyone was murdered on that attack 2 years ago...',
    );
    await speak("Wait a second, wasn't I murdered as well?");
    await speak("Does this mean I'm a ghost?");
    await speak("I'll test it out using my axe...");
    die();
    playBloodAnimation();
  }

  Future<void> runningFromGhosts() async {
    await speak(
      'I remember now, everyone was murdered on that attack 2 years ago...',
    );
    await speak(
      'But then, if everyone is dead... Then who are those people in the village?',
    );
    await speak('THEY HAVE TO BE GHOSTS', yell: true);
    await speak("THEY'RE GONNA COME AND TAKE MY SOUL!", yell: true);
    speak(
      "They might call me Crazy Joe but not even "
      "I am crazy enough to stay in this haunted ass village. No thank you!",
    );
    await followPath2([(31, 51), (31, 59)]);
  }

  Future<void> fightingForPeace() async {
    await speak(
      'I remember now, everyone was murdered on that attack 2 years ago...',
    );
    await speak('OH THE HORROR, THE SADNESS, THE PAIN!', yell: true);
    await speak(
      "I must not let anyone else go through the same Hell as I have!",
    );
    await speak("I'll embark on a great journey to end all Wars...");
    await putOnArmor(announce: false);
    speak(
      "I'LL BRING PEACE USING THE POWER OF RELENTLESS VIOLENCE!",
      yell: true,
    );
    await followPath2([(31, 51), (31, 59)]);
  }

  Future<void> stabbingPriest() async {
    await speak(
      "NECROMANCY??? IN MY VILLAGE??? NOT AS LONG AS I'M STILL BREATHING.",
      yell: true,
    );
    await followPath(KeyLocation.churchPath);
    await patrol(KeyLocation.church.patrol, patrolSpeed: 1);
  }

  Future<void> doomsaying() async {
    await followPath(KeyLocation.villageEntrancePath);
    patrol(KeyLocation.villageMainSquare.patrol);
    await speak('DEATH IS COMING TO THIS VILLAGE!', yell: true);
  }

  Future<void> repenting() async {
    await speak(
      "What's wrong with me!? How could I even dream that a Man of God would succumb to the Devil's arts?",
    );
    await speak("The Devil is playing tricks in my head");
    await speak("I must go repent for these vile thoughts");
    await followPath(KeyLocation.churchPath);
    await speak('I MUST REPENT!', yell: true);
    await speak('*whips himself*', yell: true);
    playBloodAnimation();
  }

  Future<void> runningFromUndead() async {
    await speak("Oh, well isn't that just lovely.");
    await speak(
      "As if I didn't already have 32543 problems. "
      "Now I have to deal with Necromancy as well.",
    );
    speak("Nooope, Crazy Joe is out of here, this place is a shithole.");
    await followPath2([(31, 51), (31, 59)]);
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

extension BloodAnimation on SimpleEnemy {
  static final rng = math.Random();
  static final startPos = Vector2.all(8);

  void playBloodAnimation({
    Duration? delay,
    int count = 200,
    int maxForce = 500,
  }) =>
      add(
        ParticleSystemComponent(
          position: startPos,
          particle: Particle.generate(
            count: count,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(
                randBetween(-maxForce, maxForce),
                randBetween(-maxForce, maxForce),
              ),
              child: CircleParticle(
                paint: Paint()..color = Colors.red,
                radius: rng.nextDouble() * 2,
              ),
            ),
          ),
        ),
      );

  double randBetween(int min, int max) =>
      (rng.nextInt(max - min) + min).toDouble();
}
