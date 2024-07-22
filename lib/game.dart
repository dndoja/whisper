import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'state/state.dart';
export 'state/state.dart';

import 'characters/crazy_joe.dart';
import 'characters/player.dart';

final gameState = GameState();

class GameWidget extends StatelessWidget {
  const GameWidget({super.key});

  @override
  Widget build(BuildContext context) => BonfireWidget(
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
          // zoom: 50,
          resolution: Vector2(500, 300),
          moveOnlyMapArea: true,
        ),
        onReady: initGame,
        showCollisionArea: false,
        // collisionAreaColor: Colors.red,
        player: Knight(Vector2(40, 40)),
        map: WorldMapByTiled(
          WorldMapReader.fromAsset('village.json'),
        ),
      );
}

void initGame(BonfireGameInterface game) {
  game.add(CrazyJoeBrain(KeyLocation.crazyJoeFarm.ref.mapPosition));
}
