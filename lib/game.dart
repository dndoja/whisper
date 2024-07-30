import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:whisper/decorations/shadow_target.dart';

import 'characters/animations.dart';
import 'characters/characters.dart';
import 'core/core.dart';
import 'decorations/ritual.dart';
import 'ui/bottom_panel.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: BonfireWidget(
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
            'bottom': (_, game) => BottomPanel(game),
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
        ),
      );
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
