import 'dart:math' as math;
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

final List<GameDecoration> marketDecorations = [
  MarketHolyWater(Vector2(272, 200)),
  MarketCrystal(Vector2(270, 209)),
  MarketCrystal(Vector2(278, 209)),
  MarketCrystal(Vector2(281, 207)),
  MarketCrystal(Vector2(294, 207)),
  MarketCrystal(Vector2(296, 207)),
  MarketHolyWater(Vector2(290, 202), isCursed: false),
];

final _rng = math.Random();

class MarketHolyWater extends GameDecoration {
  MarketHolyWater(Vector2 position, {this.isCursed = true})
      : super.withSprite(
          sprite: Sprite.load(
            'bottles.png',
            srcPosition: isCursed ? Vector2(16, 0) : Vector2.zero(),
            srcSize: Vector2.all(16),
          ),
          position: position,
          size: Vector2.all(8),
        );

  final bool isCursed;
}

class MarketCrystal extends GameDecoration {
  MarketCrystal(Vector2 position)
      : super.withAnimation(
          animation: animation,
          size: Vector2.all(8),
          position: position + Vector2(-8, -16),
          lightingConfig: LightingConfig(
            radius: 4,
            blurBorder: 2,
            color: Colors.white.withOpacity(0.1),
            withPulse: true,
          ),
        );

  static Future<SpriteAnimation> get animation => SpriteAnimation.load(
        'crystals.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(32, 40),
          texturePosition: Vector2(
            _rng.nextInt(4) * 32 * 3,
            _rng.nextInt(8) * 40,
          ),
        ),
      );
}
