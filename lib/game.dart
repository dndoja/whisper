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

const gameLore =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Container(
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
                  duration: const Duration(milliseconds: 50),
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
                'Play',
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
      player: ShadowPlayer(KeyLocation.alchemistLab.br.mapPosition),
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
