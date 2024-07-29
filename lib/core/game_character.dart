import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:whisper/characters/characters.dart';

import 'core.dart';

mixin GameCharacter<T extends EntityType> on SimpleEnemy {
  bool transitioningToNewTurn = false;
  bool pausePeriodicBubbles = false;

  TextBubble? currTextBubble;
  double secondsElapsedSinceLastBubble = -1;
  FutureOr<void> showTextBubble(
    String text, {
    int? periodSeconds,
    double dt = 0,
    bool yell = false,
    void Function()? onComplete,
  }) {
    secondsElapsedSinceLastBubble += dt;
    if (periodSeconds != null &&
        (pausePeriodicBubbles ||
            (secondsElapsedSinceLastBubble >= 0 &&
                secondsElapsedSinceLastBubble < periodSeconds))) {
      return Future.value();
    }

    if (currTextBubble != null && !currTextBubble!.isRemoved) {
      remove(currTextBubble!);
    }

    secondsElapsedSinceLastBubble = 0;

    final Completer<void> completer = Completer();
    currTextBubble = TextBubble(
      text,
      onComplete: () {
        completer.complete();
        onComplete?.call();
      },
      position: Vector2(8, -24),
      yell: yell,
    );
    add(currTextBubble!);

    return completer.future;
  }

  BehaviourFlag<T> get currBehaviour;
  T get entityType;

  FutureOr<void> onStateChange(CharacterState newState);
}

extension GameCharacterX on SimpleEnemy {
  bool hasClearPathTo(GameComponent target) {
    final dir = Vector2(target.x - x, target.y - y).normalized();
    final raycastResult = raycast(
      dir,
      ignoreHitboxes: target.shapeHitboxes,
      maxDistance: distance(target),
    );
    return raycastResult == null;
  }

  KeyLocation? getCurrentKeyLocation() {
    final currPoint = Point16.fromMapPos(absoluteCenter);
    return KeyLocation.values.firstOrNullWhere((l) => l.contains(currPoint));
  }

  Iterable<GameCharacter> nearbyCharacters() {
    final currPoint = Point16.fromMapPos(absoluteCenter);
    final List<(GameCharacter, int)> charactersByDistance = [];

    for (final character in characterTracker.allAlive) {
      if (character == this) continue;
      final distSquared = currPoint.distanceSquaredTo(
        Point16.fromMapPos(character.absoluteCenter),
      );
      if (distSquared <= visionRadiusSquared) {
        charactersByDistance.add((character, distSquared));
      }
    }

    return charactersByDistance.sortedBy((cbd) => cbd.$2).map((cbd) => cbd.$1);
  }

  int distSquaredTo(GameCharacter other) {
    final currPoint = Point16.fromMapPos(absoluteCenter);
    final otherPoint = Point16.fromMapPos(other.absoluteCenter);
    return currPoint.distanceSquaredTo(otherPoint);
  }

  bool isInAttackRange(GameCharacter target) =>
      distSquaredTo(target) <= attackRangeSquared;

  bool tryAttack(GameCharacter target) {
    if (!isInAttackRange(target)) return false;

    target
      ..removeLife(target.maxLife)
      ..playBloodAnimation();

    return true;
  }
}
