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
  a('characters-a.png'),
  b('characters-b.png'),
  c('characters-c.png'),
  d('characters-d.png'),
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

enum DeathAnimation { dying }

class Animations {
  static final SimpleDirectionAnimation undead =
      Animations.forCharacter(CharacterSheet.monsters, 0, null);

  static final SimpleDirectionAnimation knight =
      forCharacter(CharacterSheet.d, 7, 'knight', attackFramesCount: 3);

  static final SimpleDirectionAnimation crazyJoe =
      forCharacter(CharacterSheet.b, 1, 'crazy-joe', attackFramesCount: 4);

  static SimpleDirectionAnimation forDeadCharacter(String animationPrefix) {
    final animation = SpriteAnimation.load(
      '$animationPrefix-dead.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        loop: true,
        stepTime: 1,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(96, 0),
      ),
    );

    return SimpleDirectionAnimation(idleRight: animation, runRight: animation);
  }

  static SimpleDirectionAnimation forCharacter(
    CharacterSheet sheet,
    int charIndex,
    String? prefix, {
    bool invertHorizontal = false,
    Map<dynamic, Future<SpriteAnimation>> others = const {},
    int? attackFramesCount,
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

    final Map<dynamic, Future<SpriteAnimation>> othersEffective = {
      if (prefix != null) ...{
        DeathAnimation.dying: SpriteAnimation.load(
          '$prefix-dead.png',
          SpriteAnimationData.sequenced(
            amount: 4,
            loop: false,
            stepTime: 0.15,
            textureSize: Vector2.all(32),
          ),
        ),
        if (attackFramesCount != null) ...{
          AttackAnimation.right: SpriteAnimation.load(
            '$prefix-attack-right.png',
            SpriteAnimationData.sequenced(
              amount: attackFramesCount,
              loop: false,
              stepTime: 0.1,
              textureSize: Vector2.all(32),
            ),
          ),
          AttackAnimation.left: SpriteAnimation.load(
            '$prefix-attack-left.png',
            SpriteAnimationData.sequenced(
              amount: attackFramesCount,
              loop: false,
              stepTime: 0.1,
              textureSize: Vector2.all(32),
            ),
          ),
        },
      },
      ...others,
    };

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
      others: othersEffective,
    );
  }
}
