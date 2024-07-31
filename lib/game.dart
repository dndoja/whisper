import 'package:bonfire/bonfire.dart' hide TypeWriter;
import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:whisper/decorations/shadow_target.dart';

import 'characters/animations.dart';
import 'characters/characters.dart';
import 'core/core.dart';
import 'decorations/ritual.dart';
import 'ui/ui.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            for (final platform in TargetPlatform.values)
              platform: const NoTransitionsBuilder(),
          }),
        ),
        home: const HomeScreen(),
      );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}

const gameLore = 'You are a Divine Shadow, a hand of the God of Death. '
    'Your job is to maintain balance in the universe by ensuring that the cycle of Life and Death continues undisturbed.'
    "This means that you need to thwart whatever attempts Mortals make at achieving immortality. For this mission, you will need to stop a human Alchemist from completing a ritual that will grant him immortality. Also, you cannot interact with the physical world, so you'll have to achieve your goals by planting thoughts into weak mortals' heads to get them to do your bidding.";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black,
        child: Column(
          children: [
            const Text(
              'Whisper',
              style: TextStyle(
                fontSize: 88,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            Expanded(
              child: SizedBox(
                width: 800,
                child: TypeWriter.text(
                  gameLore,
                  duration: const Duration(milliseconds: 20),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TheGame()),
              ),
              child: const Text(
                'Start',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const Spacer(),
          ],
        ),
      );
}

class TheGame extends StatelessWidget {
  const TheGame();

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      playerControllers: [
        Keyboard(
          config: KeyboardConfig(
            enable: true,
            directionalKeys: [
              KeyboardDirectionalKeys.wasd(),
            ],
          ),
        ),
      ],
      cameraConfig: CameraConfig(
        zoom: 4,
        moveOnlyMapArea: true,
      ),
      overlayBuilderMap: {
        'bottom': (_, game) => UI(game),
      },
      lightingColorGame: Colors.black.withOpacity(0.4),
      // showCollisionArea: true,
      initialActiveOverlays: const ['bottom'],
      onReady: initGame,
      player: ShadowPlayer(const Point16(31, 32).mapPosition - Vector2(16, 16)),
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('village.json'),
        objectsBuilder: {
          'ritual-fire': (d) => RitualFire(d.position),
          'ritual-holy-water': (d) => RitualHolyWater(d.position),
          'ritual-holy-water-cursed': (d) =>
              RitualHolyWater(d.position, isCursed: true),
          'ritual-scroll': (d) => RitualScroll(d.position),
        },
      ),
    );
  }
}

void initGame(BonfireGameInterface game) {
  game.addAll([
    characterTracker.register(CrazyJoeController()),
    characterTracker.register(PriestController()),
    characterTracker.register(FishermanController()),
    // characterTracker.register(RolfController()),
    characterTracker.register(AstrologerController()),
    characterTracker.register(AlchemistController()),
    ShadowTarget(),
  ]);
}
