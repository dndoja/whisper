import 'package:bonfire/bonfire.dart';
import 'package:whisper/game.dart';

import 'animations.dart';

class CrazyJoeBrain extends SimpleEnemy
    with BlockMovementCollision, RandomMovement, GameCharacter<CrazyJoe> {
  CrazyJoeBrain(Vector2 position)
      : super(
          size: Vector2.all(16),
          position: position,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        ) {
    subscribeToGameState(gameState);
  }

  CharacterState<CrazyJoe> state = CharacterState(
    entityType: const CrazyJoe(),
    behavior: const CrazyJoeChilling(),
  );

  @override
  CrazyJoe get character => const CrazyJoe();

  @override
  Future<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    switch (state.behavior) {
      case CrazyJoeChilling():
        patrolFarm(dt);
      case EntityAtKeyLocation<CrazyJoe>():
      case EntityMentalState<CrazyJoe>():
      case CrazyJoeRampaging():
    }
    super.update(dt);
  }

  void patrolFarm(double dt) {
    final List<Direction> allowedDirections = [];
    final Vector2 currPos = absoluteCenter.clone();

    for (final dir in Direction.values) {
      final dirVec2 = dir.toVector2();
      final nextLoc = currPos + dirVec2 * 32;
      final nextPoint = Point16.fromMapPos(nextLoc);
      final isValid = KeyLocation.crazyJoeFarm.contains(nextPoint);
      // print('${Point16.fromMapPos(currPos)} ${dir.name} -> $nextPoint, $isValid');
      if (isValid) allowedDirections.add(dir);
    }

    if (allowedDirections.isNotEmpty) {
      runRandomMovement(
        dt,
        directions: RandomMovementDirections(values: allowedDirections),
        timeKeepStopped: 500,
      );
    }
  }

  @override
  void onStateChange(CharacterState<CrazyJoe> newState) {}
}
