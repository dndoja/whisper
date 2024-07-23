import 'package:bonfire/bonfire.dart';
import 'package:whisper/game.dart';

import 'animations.dart';

class CrazyJoeBrain extends SimpleEnemy
    with
        // BlockMovementCollision,
        RandomMovement,
        GameCharacter<CrazyJoe>,
        PathFinding {
  CrazyJoeBrain(Vector2 position)
      : super(
          size: Vector2.all(16),
          position: position,
          animation: PlayerSpriteSheet.simpleDirectionAnimation,
        ) {
    subscribeToGameState();
  }

  BehaviourFlag<CrazyJoe> prevBehaviour = const CrazyJoeChilling();
  BehaviourFlag<CrazyJoe> currBehaviour = const CrazyJoeChilling();

  @override
  bool transitioningToNewTurn = false;

  @override
  CrazyJoe get character => const CrazyJoe();

  @override
  void update(double dt) {
    switch (currBehaviour) {
      case CrazyJoeChilling():
        patrolFarm(dt);
      case CrazyJoeRampaging():
      case EntityAtKeyLocation<CrazyJoe>():
      case EntityMentalState<CrazyJoe>():
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
  void onStateChange(CharacterState newState) {
    if (newState.behaviour != currBehaviour) {
      prevBehaviour = currBehaviour;
      currBehaviour = newState.behaviour as BehaviourFlag<CrazyJoe>;

      turnTransitionStart();
      switch (currBehaviour) {
        case CrazyJoeRampaging():
          gameRef.camera.follow(this);
          moveToPositionWithPathFinding(
            const Point16(50, 50).mapPosition,
            onFinish: turnTransitionEnd,
          );
        case CrazyJoeChilling():
          turnTransitionEnd();
      }
    } else {
      turnTransitionEnd();
    }
  }
}
