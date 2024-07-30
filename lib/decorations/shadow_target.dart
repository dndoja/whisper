import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';
import 'package:whisper/core/game_character.dart';
import 'package:whisper/ui/bottom_panel.dart';

import 'ritual.dart';

ShadowTarget? _instance;
ShadowTarget get shadowTarget => _instance!;

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
    BottomPanel.setTendrilsTarget(target?.entityType);
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
