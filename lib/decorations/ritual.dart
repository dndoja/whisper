import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';

final Vector2 size32 = Vector2.all(32);
final List<HiddenByDefault> ritualDecorations = [];

class RitualDecorations {
  static GameDecoration fire(Vector2 position) => RitualFire(position);
  static GameDecoration holyWater(
    Vector2 position, {
    bool isCorrupted = false,
  }) =>
      RitualHolyWater(position, isCursed: isCorrupted);
}

mixin HiddenByDefault on GameComponent {
  @override
  Future<void> onLoad() {
    isVisible = false;
    return super.onLoad();
  }
}

class RitualHolyWater extends GameDecoration with HiddenByDefault {
  RitualHolyWater(Vector2 position, {this.isCursed = false})
      : super.withSprite(
          sprite: Sprite.load(
            'bottles.png',
            srcPosition: isCursed ? Vector2(16, 0) : Vector2.zero(),
            srcSize: Vector2.all(16),
          ),
          position: position,
          size: Vector2.all(8),
        ) {
    if (KeyLocation.ritualSite.contains(Point16.fromMapPos(position))) {
      ritualDecorations.add(this);
    }
  }

  final bool isCursed;
}

class RitualFire extends GameDecoration with HiddenByDefault {
  RitualFire(Vector2 position)
      : super.withAnimation(
          animation: animation,
          size: size32,
          position: position + Vector2(-8, -16),
          lightingConfig: LightingConfig(
            radius: size32.x / 2,
            blurBorder: size32.x / 2,
            color: Colors.blueGrey.withOpacity(0.1),
            withPulse: true,
          ),
        ) {
    ritualDecorations.add(this);
  }

  static final animation = SpriteAnimation.load(
    'lights.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: size32,
      // texturePosition: Vector2(0, 64),
    ),
  );
}

class RitualEclipseLight extends GameDecoration with Movement {
  RitualEclipseLight()
      : super(
          size: size32,
          position: const Point16(77, 1).mapPosition,
          lightingConfig: LightingConfig(
            radius: 240,
            blurBorder: size32.x,
            color: Colors.blue.withOpacity(0.15),
            withPulse: false,
          ),
        );

  final Completer _completer = Completer();
  Future<void> get onReachRitualSite => _completer.future;

  @override
  void update(double dt) {
    final point = Point16.fromMapPos(absoluteCenter);
    if (_completer.isCompleted) {
      return super.update(dt);
    }

    if (point == KeyLocation.ritualSite.ref) {
      _completer.complete();
      stopMove();
    } else {
      moveToPosition(KeyLocation.ritualSite.ref.mapPosition);
    }

    super.update(dt);
  }
}

class RitualScroll extends GameDecoration with HiddenByDefault {
  RitualScroll(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('scroll.png', srcSize: Vector2.all(16)),
          position: position,
          size: Vector2.all(16),
        ) {
    ritualDecorations.add(this);
  }
}
