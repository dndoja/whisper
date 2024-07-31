import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/game_character.dart';
import 'package:whisper/ui/ui.dart';

import 'decorations.dart';

ShadowTarget? _instance;
ShadowTarget get shadowTarget => _instance!;

class ShadowCard extends GameDecoration with HiddenByDefault {
  ShadowCard(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('shadow-card.png'),
          position: position,
          size: Vector2(5, 8),
          lightingConfig: LightingConfig(
            color: Colors.deepPurpleAccent.withOpacity(0.3),
            blurBorder: 4,
            radius: 8,
            withPulse: true,
            pulseSpeed: 0.2,
          ),
          objectPriority: 0,
        );
}

class ShadowTarget extends GameDecoration {
  ShadowTarget()
      : super.withAnimation(
          animation: animation,
          size: Vector2.all(24),
          position: Vector2.zero(),
          objectPriority: 20,
        ) {
    _instance = this;
  }

  GameCharacter? _target;
  set target(GameCharacter? target) {
    if (_target == target) return;
    _target = target;
    syncPosition();
    UI.setTendrilsTarget(target?.entityType);
  }

  static final animation = SpriteAnimation.load(
    'shadow-target.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.15,
      textureSize: Vector2.all(16),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    syncPosition();
  }

  void syncPosition() {
    final nextPosition = _target?.absoluteCenter;
    position = (nextPosition ?? Vector2.zero()) - Vector2(12, 8);
  }
}
