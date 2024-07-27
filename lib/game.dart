import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'characters/characters.dart';
import 'core/core.dart';
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
          initialActiveOverlays: const ['bottom'],
          onReady: initGame,
          player: ShadowPlayer(KeyLocation.church.br.mapPosition),
          map: WorldMapByTiled(
            WorldMapReader.fromAsset('village.json'),
          ),
        ),
      );
}

void initGame(BonfireGameInterface game) {
  game.addAll([
    characterTracker.register(CrazyJoeController(KeyLocation.crazyJoeFarm.ref.mapPosition)),
    characterTracker.register(PriestController(KeyLocation.church.ref.mapPosition)),
  ]);
}
