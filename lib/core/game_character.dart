import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:whisper/characters/animations.dart';
import 'package:whisper/characters/characters.dart';
import 'package:whisper/decorations/shadow_target.dart';

import 'core.dart';

mixin GameCharacter<T extends EntityType> on SimpleEnemy, SimpleMovement2 {
  bool transitioningToNewTurn = false;
  bool pausePeriodicBubbles = false;
  bool playingDeathAnimation = false;

  late String animationPrefix = entityType.animationPrefix;
  late final ShadowCard shadowCard = ShadowCard(Vector2(9, 4));

  void showShadowCard() => shadowCard.isVisible = true;

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        anchor: Anchor.center,
        position: Vector2(12, 16),
        radius: 4,
      ),
    );
    add(shadowCard);
    return super.onLoad();
  }

  void die() {
    if (playingDeathAnimation) return;

    playingDeathAnimation = true;
    pausePatrolling(forceStop: true);
    animation?.playOnceOther(
      DeathAnimation.dying,
      onFinish: () {
        replaceAnimation(
          Animations.forDeadCharacter(animationPrefix),
          doIdle: true,
        );
        removeLife(maxLife);
        playingDeathAnimation = false;
      },
    );
  }

  TextBubble? currTextBubble;
  double secondsElapsedSinceLastBubble = -1;
  final Set<(MentalTrait, Level)> shownMentalStatusUpdates = {};
  FutureOr<void> showMentalStateUpdates(Map<MentalTrait, Level> mentalStates) {
    final List<(MentalTrait, Level)> toShow = mentalStates.entries
        .map((e) => (e.key, e.value))
        .whereNot(shownMentalStatusUpdates.contains)
        .toList();
    if (toShow.isEmpty) return Future.value();

    if (currTextBubble != null && !currTextBubble!.isRemoved) {
      remove(currTextBubble!);
    }

    final StringBuffer statusMessage = StringBuffer();
    statusMessage.write('${entityType.name} has become ');

    for (int i = 0; i < toShow.length; i++) {
      final (mentalTrait, level) = toShow[i];
      statusMessage.write('${level.name} ${mentalTrait.name}');
      if (i < toShow.length - 2) {
        statusMessage.write(', ');
      } else if (i < toShow.length - 1) {
        statusMessage.write(' and ');
      } else {
        statusMessage.write('.');
      }
    }

    shownMentalStatusUpdates.addAll(toShow);

    final Completer<void> completer = Completer();
    currTextBubble = TextBubble(
      statusMessage.toString(),
      onComplete: completer.complete,
      position: Vector2(8, -24),
      status: true,
    );
    add(currTextBubble!);

    return completer.future;
  }

  FutureOr<void> speak(
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

  @mustCallSuper
  FutureOr<void> onStateChange(CharacterState newState) {
    shadowCard.isVisible = false;
  }
}

mixin Attacker on SimpleEnemy {
  bool inAttackAnimation = false;
  final Set<EntityType> attacked = {};

  bool tryAttack(GameCharacter nearbyVictim, {Function()? onFinish}) {
    if (!isInAttackRange(nearbyVictim)) return false;
    inAttackAnimation = true;
    stopMove();
    nearbyVictim.pausePatrolling(forceStop: true);

    animation?.playOnceOther(
      AttackAnimation.fromAngle(getAngleFromTarget(nearbyVictim)),
      onFinish: () {
        inAttackAnimation = false;
        nearbyVictim.die();
        if (!attacked.contains(nearbyVictim.entityType)) {
          onFinish?.call();
          attacked.add(nearbyVictim.entityType);
        }
      },
    );

    return true;
  }
}

extension GameCharacterX on SimpleEnemy {
  bool hasClearPathTo(GameComponent target) {
    if (distance(target) > 16 * 8) return false;
    final dir = Vector2(target.x - x, target.y - y).normalized();
    final dist = distance(target);
    final raycastResult = raycast(
      dir,
      ignoreHitboxes: target.shapeHitboxes,
      maxDistance: distance(target),
    );
    // print('$dist, ${raycastResult == null}');
    return distance(target) < 16 * 8 && raycastResult == null;
  }

  KeyLocation? currentKeyLocation() {
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

  bool isInAttackRange(GameCharacter target) => distance(target) <= 24;

  bool tryAttack(GameCharacter target) {
    if (!isInAttackRange(target)) return false;

    target
      ..removeLife(target.maxLife)
      ..playBloodAnimation();

    return true;
  }
}
