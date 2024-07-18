import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'actors/actors.dart';

class WhisperGame extends FlameGame {
  WhisperGame();

  TheShadow? theShadow;

  @override
  Future<void> onLoad() async {
    print('Loading the game');
    await images.loadAll(const [
      'ember.png',
      'shadow.png',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;

    theShadow = TheShadow(
      position: Vector2(400, canvasSize.y - 270),
    );
    world.add(theShadow!);
  }

  @override
  Color backgroundColor() => Colors.blueGrey;
}
