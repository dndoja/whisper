import 'dart:math' as math;
import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/core.dart';

class KeyLocationComponent extends GameComponent {
  KeyLocationComponent([this._keyLocation]);

  KeyLocation? _keyLocation;
  KeyLocation? get keyLocation => _keyLocation;

  set keyLocation(KeyLocation? keyLocation) {
    _keyLocation = keyLocation;
    position = keyLocation?.ref.mapPosition ?? Vector2.zero();
  }
}

enum CharacterSheet {
  a('characters_a.png'),
  b('characters_b.png'),
  c('characters_c.png'),
  d('characters_d.png'),
  monsters('monsters.png'),
  ;

  const CharacterSheet(this.assetName);
  final String assetName;
}

enum AttackAnimation {
  left,
  right,
  ;

  static AttackAnimation fromAngle(double angle) =>
      angle >= -(math.pi / 2) && angle <= math.pi / 2
          ? AttackAnimation.right
          : AttackAnimation.left;
}

class Animations {
  static Future<SpriteAnimation> knightAttackRight = SpriteAnimation.load(
    'knight_attack_right.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      loop: false,
      stepTime: 0.1,
      textureSize: Vector2.all(32),
    ),
  );

  static Future<SpriteAnimation> knightAttackLeft = SpriteAnimation.load(
    'knight_attack_left.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      loop: false,
      stepTime: 0.1,
      textureSize: Vector2.all(32),
    ),
  );

  static SimpleDirectionAnimation knight = forCharacter(
    CharacterSheet.d,
    7,
    others: {
      AttackAnimation.left: knightAttackLeft,
      AttackAnimation.right: knightAttackRight,
    },
  );

  static SimpleDirectionAnimation forCharacter(
    CharacterSheet sheet,
    int charIndex, {
    bool invertHorizontal = false,
    Map<dynamic, Future<SpriteAnimation>> others = const {},
  }) {
    const charsPerSheet = 4;
    const charSize = 32.0;
    const stepTime = 0.2;
    const framesPerRow = 3;
    const framesPerCol = 4;

    final charSpritesTopLeft = Vector2(
      (charIndex % charsPerSheet) * charSize * framesPerRow,
      (charIndex ~/ charsPerSheet) * charSize * framesPerCol,
    );
    final textureSize = Vector2(charSize, charSize);

    final Future<SpriteAnimation> runDown = SpriteAnimation.load(
      sheet.assetName,
      SpriteAnimationData.sequenced(
        amount: framesPerRow,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: charSpritesTopLeft,
      ),
    );
    Future<SpriteAnimation> runLeft = SpriteAnimation.load(
      sheet.assetName,
      SpriteAnimationData.sequenced(
        amount: framesPerRow,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: charSpritesTopLeft + Vector2(0, charSize),
      ),
    );
    Future<SpriteAnimation> runRight = SpriteAnimation.load(
      sheet.assetName,
      SpriteAnimationData.sequenced(
        amount: framesPerRow,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: charSpritesTopLeft + Vector2(0, charSize * 2),
      ),
    );
    final Future<SpriteAnimation> runUp = SpriteAnimation.load(
      sheet.assetName,
      SpriteAnimationData.sequenced(
        amount: framesPerRow,
        stepTime: stepTime,
        textureSize: textureSize,
        texturePosition: charSpritesTopLeft + Vector2(0, charSize * 3),
      ),
    );

    if (invertHorizontal) (runLeft, runRight) = (runRight, runLeft);

    return SimpleDirectionAnimation(
      idleRight: SpriteAnimation.load(
        sheet.assetName,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: textureSize,
          texturePosition: charSpritesTopLeft + Vector2(charSize, 0),
        ),
      ),
      runDown: runDown,
      runLeft: runLeft,
      runRight: runRight,
      runUp: runUp,
      others: others,
    );
  }
}
