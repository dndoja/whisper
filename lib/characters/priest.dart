import 'package:bonfire/bonfire.dart';
import 'package:whisper/characters/characters.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/decorations/market.dart';

import 'animations.dart';
import 'undead.dart';

class PriestController extends SimpleEnemy
    with
        BlockMovementCollision,
        SimpleMovement2,
        GameCharacter<Priest>,
        PathFinding {
  PriestController()
      : super(
          animation: Animations.forCharacter(CharacterSheet.c, 2, 'priest'),
          size: Vector2.all(24),
          position: KeyLocation.church.ref.mapPosition + spawnOffset,
          receivesAttackFrom: AcceptableAttackOriginEnum.ALL,
        );

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
    if (gameState.isPaused) return;

    switch (currBehaviour) {
      case PriestScamming() when !transitioningToNewTurn:
        speak(
          "Totally real and working holy artifacts for sale, 50% off!",
          periodSeconds: 10,
          yell: true,
          dt: dt,
        );
      case PriestSelfFlagellating() when !transitioningToNewTurn:
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

      case PriestSelfPitying() when !transitioningToNewTurn:
        speak('I suck.', dt: dt, periodSeconds: 10);

      default:
    }
    super.update(dt);
  }

  @override
  Future<void> onStateChange(CharacterState newState) async {
    super.onStateChange(newState);
    if (newState.behaviour == currBehaviour) return;

    currBehaviour = newState.behaviour as BehaviourFlag<Priest>;

    switch (currBehaviour) {
      case PriestScamming():
        await scamming();
      case PriestHustling():
        await hustling();
      case PriestUpholdingGodsWill():
        await upholdingGodsWill();
      case PriestThreateningInquisition():
        await threateningInquisition();
      case PriestAskingForIndulgences():
        await askingForIndulgences();
      case PriestRediscoveringFaith():
        await rediscoveringFaith();
      case PriestSelfFlagellating():
        await selfFlagellating();
      case PriestNecromancing():
        await necromancing();
      case PriestSelfPitying():
        await selfPitying();
      case PriestAbolishingGreed():
        await abolishingGreed();
      case PriestRidiculingNecromancy():
        await ridiculingNecromancy();
      case PriestPraying():
        break;
    }
  }

  Future<void> scamming() async {
    await speak("You know what, I'm done.");
    await speak(
      "All of these years devoted to the Church and what do I get in return?",
    );
    await speak("Nothing, not a dime.");
    await speak("From now on I'm following my dad's footsteps.");
    await speak(
        "Although I don't know them exactly because he left us when I was 3.");
    await followPath(Paths.churchToMarket);
    await speak("First things first, let's get rid of all this Church Merch.");
    gameRef.addAll(marketDecorations);
    await speak(
      "Totally real and working holy artifacts for sale, 50% off!",
      yell: true,
    );
  }

  Future<void> hustling() async {
    await speak("You know what, I'm done.");
    await speak(
      "All of these years devoted to the Church and what do I get in return?",
    );
    await speak("Nothing, not a dime.");
    await speak(
      "From now on I'll be following my great uncle's footsteps and become a businessman.",
    );
    await followPath(Paths.churchToMarket);
    await speak(
      "Let's start by selling these useless Holy items.",
    );
    gameRef.addAll(marketDecorations);
    await speak(
      "Holy artifacts and curios for sale, 20% off!",
      yell: true,
    );
  }

  Future<void> upholdingGodsWill() async {
    await speak("I AM A BEACON OF GOD'S LIGHT", yell: true);
    await speak("A CHAMPION OF HIS HOLY CAUSE", yell: true);
    await speak(
      "EVEN IF EVERY LIMB OF MY BODY GETS CUT OFF AND EVERY SINGLE BONE GETS CRUMBLED TO DUST",
      yell: true,
    );
    await speak(
      "IF IT IS BY HIS WILL, I WILL GLADLY TAKE ON ANY HARDSHIP",
      yell: true,
    );
  }

  Future<void> threateningInquisition() async {
    await speak(
      'HEAR YE, HEAR YE! God has spoken to me and he is worried that you people lack faith. ',
      yell: true,
    );
    await speak(
      "Now unless we want the Inquisition to get involved y'all better start paying your Indulgences!",
      yell: true,
    );
  }

  Future<void> askingForIndulgences() async {
    await speak(
      'HEAR YE, HEAR YE! God has spoken to me and he is worried that you people lack faith. ',
      yell: true,
    );
    await speak(
      "The best way to show your love to God is by paying your indulgences!",
      yell: true,
    );
  }

  Future<void> selfFlagellating() async {
    await speak("I have let these people down!");
    await speak(
      "I was supposed to make them love God but they have all turned into non-believers.",
    );
    await speak("Well, except for Joe I suppose.");
    await speak("I must repent for my failures.");
    await followPath2([(31, 13)]);
    await speak('I MUST REPENT!', yell: true);
    await speak('*whips himself*', yell: true);
    playBloodAnimation();
  }

  Future<void> necromancing() async {
    await speak("Such... Power... It cannot be controlled...", yell: true);
    await speak('IT MUST BE UNLEASHED!', yell: true);
    await followPath(Paths.churchToGraveyard);
    await speak('*Chants in Latin*', yell: true);
    gameRef.addAll(List.generate(10, (_) => Undead()));
    gameRef.camera.follow(undeadCaptain);
    await undeadCaptain.massacreCompleter.future;
  }

  Future<void> rediscoveringFaith() async {
    await speak('I... I have failed these people.');
    await speak(
      'I was supposed to shepherd them towards the light, but I let them go astray.',
    );
    await speak('It all happened because my own Faith was shaken and frail.');
    await speak(
      "BUT I SEE IT NOW, YOU WERE THERE ALL ALONG WEREN'T YOU OH ALL MIGHTY FATHER",
      yell: true,
    );
    await speak(
      'I WILL RISE UP AGAIN TO MY HOLY TASK AND I WILL NOT FAIL THIS TIME.',
      yell: true,
    );
  }

  Future<void> selfPitying() async {
    await speak(
        'A pathetic failure like me could never even dream of ruling the world.');
    await speak("I can't even rule over my own house...");
    await speak("And it's not even a house it's a damn Church.");
    await speak("It's not even mine...");
    await speak('I suck.');
  }

  Future<void> abolishingGreed() async {
    await speak(
      "Such a barren world... I was the ruler, but ruler of what? "
      "A desolace place walked only by the living dead. What a horrible fate...",
    );
    await speak("I must let go of this Gluttony that has taken over me.");
    await speak(
      "GOD, PLEASE FORGIVETH ME, YOUR SERVANT, FOR I LET MYSELF GET INFLUENCED BY THE DEVIL!",
      yell: true,
    );
  }

  Future<void> ridiculingNecromancy() async {
    await speak('AHAHAHAHAHAHAHAHA SOMEONE PLANTED AN ILLUSION IN MY HEAD',
        yell: true);
    await speak(
        'You really thought you could influence me with a silly power fantasy you piece of shit?');
    await speak("Woo hoo look at me Im a Necromancer, I'm so stwong :>");
    await speak("AS LONG AS I HAVE GOD ON MY SIDE I HAVE NO WEAKNESS!",
        yell: true);
    await speak('Get out of my fucking face');
  }
}
