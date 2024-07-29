import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:whisper/core/core.dart';

import 'transitions.dart';

export 'key_locations.dart';

part 'actions.dart';

final GameState gameState = GameState();

class StateTransition {
  const StateTransition(
    this.preRequisites,
    this.next, {
    this.duration = 1,
  });
  final List<EntityFlag> preRequisites;
  final int duration;
  final List<EntityFlag> next;

  @override
  String toString() => '$preRequisites -> $next ($duration)';
}

class CharacterState<T extends EntityType> {
  CharacterState({
    required this.entityType,
    required this.behaviour,
    int? sanityLevel,
    Map<MentalTrait, Level>? mentalStates,
    this.updatedAt = 0,
  })  : mentalStates = mentalStates != null ? Map.of(mentalStates) : {},
        sanityLevel = sanityLevel ?? entityType.initialSanity;

  final T entityType;
  final int updatedAt;

  int sanityLevel;
  int soulWhisperCount = 0;
  BehaviourFlag<T> behaviour;

  final Map<MentalTrait, Level> mentalStates;

  CharacterState<T> cloneIn(int turnNumber) => CharacterState(
        entityType: entityType,
        behaviour: behaviour,
        sanityLevel: sanityLevel,
        mentalStates: Map.of(mentalStates),
        updatedAt: turnNumber,
      );

  void boostMentalState(MentalTrait state, [int levels = 1]) {
    assert(levels > 0, 'levels should be > 0');
    final currLevel = mentalStates[state] ?? Level.none;
    final nextIndex = math.min(
      currLevel.index + levels,
      Level.values.lastIndex,
    );
    mentalStates[state] = Level.values[nextIndex];
  }

  Iterable<EntityFlag<T>> flags() sync* {
    final MentalTrait? dominantMentalTrait =
        mentalStates.entries.maxBy((e) => e.value.index)?.key;
    if (dominantMentalTrait != null) {
      yield DominantMentalTrait(entityType, dominantMentalTrait);
    }
    yield behaviour;
    yield CurrentMentalState(entityType, mentalStates);
    yield SanityLevel(entityType, sanityLevel);
    yield EntityActionCount(
      entityType,
      TurnActionType.darkWhispers,
      soulWhisperCount,
    );
  }
}

extension GameCharacterStateX on GameCharacter {
  void subscribeToGameState() => gameState._listeners.add(this);

  Future<void> _runTurnTransition(
    CharacterState newState, {
    required bool isLast,
  }) async {
    print('Running turn transition on $entityType');
    transitioningToNewTurn = true;
    final Completer<void> cameraCompleter = Completer();
    gameRef.camera.moveToTargetAnimated(
      target: this,
      onComplete: cameraCompleter.complete,
      effectController: EffectController(duration: isVisible ? 0.2 : 1),
    );
    await cameraCompleter.future;

    await onStateChange(newState);

    await Future.delayed(const Duration(seconds: 1));

    // print('Finished turn transition on $entityType');
    if (!transitioningToNewTurn) return;
    gameState._nextTransition(entityType);
    transitioningToNewTurn = false;

    if (isLast) {
      if (newState.behaviour.endsInLeavingMap ||
          entityType == const Alchemist()) {
        gameRef.camera.moveToPlayerAnimated();
      } else {
        gameRef.player!.position = position + Vector2(0, 16);
        gameRef.camera.follow(gameRef.query<SimplePlayer>().first);
      }
    }
  }
}

class GameState {
  GameState() {
    endTurn();
  }

  final Map<EntityType, List<CharacterState>> entityStates = {};
  final Map<StateTransition, int> ongoingTransitions = {};

  final List<GameCharacter> _listeners = [];
  final Queue<GameCharacter> _turnTransitionQueue = Queue();

  int currentTurn = 0;
  EntityType? lockedBy;

  bool isPaused = false;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Turn: $currentTurn');

    buffer.writeln('State:');
    for (final entityType in entityStates.keys) {
      final state = entityStates[entityType]!.lastOrNull;
      if (state == null) continue;

      final name = entityType.toString();
      final physicalState =
          state.behaviour.toString().removePrefix(name).decapitalize();
      buffer
        ..write(entityType.toString())
        ..write(': $physicalState')
        ..write(', ${state.mentalStates}')
        ..write(', sanity=${state.sanityLevel}')
        ..write(' (mut: ${state.updatedAt})')
        ..writeln();
    }

    return buffer.toString();
  }

  Iterable<TurnAction> availableActionsFor(EntityType entity) sync* {
    final Iterable<EntityFlag> currFlags =
        entityStates[entity]?.lastOrNull?.flags() ?? const [];
    final List<ActionGroup> actionGroups = entityAvailableOptions[entity] ?? [];

    print(entity);
    print(currFlags);

    for (final group in actionGroups) {
      print(group.conditions);
      if (flagsMatchPreReqs(currFlags, preReqs: group.conditions)) {
        print('match');
        yield* group.actions;
      }
    }
  }

  CharacterState ofCharacter(EntityType entity) => entityStates[entity]!.last;

  Iterable<(EntityType, String)> characterDialogs() sync* {
    for (final entity in entityDialogs.keys) {
      final EntityDialogs dialogs = entityDialogs[entity]!;

      final List<CharacterState> states = entityStates[entity] ?? const [];
      if (states.length < 2) continue;

      final CharacterState prev = states[states.length - 2];
      final CharacterState curr = states[states.length - 1];

      final bool hasNewBehaviour = curr.behaviour != prev.behaviour;
      if (hasNewBehaviour) {
        final dialog = dialogs.forBehaviours[curr.behaviour];
        if (dialog != null) {
          yield (entity, dialog);
          continue;
        }
      }

      for (final trait in curr.mentalStates.keys) {
        final Level currLvl = curr.mentalStates[trait]!;
        final Level prevLvl = prev.mentalStates[trait] ?? Level.none;

        if (currLvl.index > prevLvl.index) {
          final dialog = dialogs.forMentalTraits[(trait, currLvl)];
          if (dialog != null) {
            yield (entity, dialog);
            continue;
          }
        }
      }
    }
  }

  void endTurn([Map<EntityType, TurnAction> turnActions = const {}]) {
    if (lockedBy != null || isPaused) return;

    final List<List<StateTransition>> potentialTransitions = [
      ...stateTransitions
    ];

    final Set<EntityType> updated = {};

    for (final entry in turnActions.entries) {
      final target = entry.key;
      final history = entityStates[target]!;
      if (history.last.updatedAt < currentTurn) {
        history.add(history.last.cloneIn(currentTurn));
      }
      final CharacterState targetState = history.last;

      switch (entry.value) {
        case DarkWhispers(
            :final mentalState,
            :final mentalStateLevelIncrease,
            :final sanityDamage,
          ):
          targetState
            ..boostMentalState(mentalState, mentalStateLevelIncrease)
            ..soulWhisperCount += 1
            // SoulWhisper cannot reduce Sanity below 1
            ..sanityLevel = math.max(1, targetState.sanityLevel - sanityDamage);
          updated.add(entry.key);

        case VisionsOfMadness(:final transitions):
          targetState.sanityLevel = 0;
          potentialTransitions.add(transitions);
      }
    }

    final List<EntityFlag> currentStates = entityStates.values
        .expand<EntityFlag>((v) => v.lastOrNull?.flags() ?? const [])
        .toList();

    final List<StateTransition> stagedTransitions = [];
    for (final group in potentialTransitions) {
      for (final transition in group.reversed) {
        if (transition.preRequisites.isEmpty && currentTurn > 0) continue;

        final bool canApply = flagsMatchPreReqs(
          currentStates,
          preReqs: transition.preRequisites,
        );

        if (canApply) {
          stagedTransitions.add(transition);
          break;
        }
      }
    }

    bool shouldFastForwardAlchemist = false;

    for (final transition in stagedTransitions) {
      final int startedAt = ongoingTransitions[transition] ??= currentTurn;
      final bool isReady = currentTurn + 1 - startedAt >= transition.duration;

      if (!isReady) continue;

      for (final nextState in transition.next) {
        final List<CharacterState> stateHistory =
            entityStates[nextState.type] ??= [];
        final CharacterState? prev = stateHistory.lastOrNull;

        if (prev == null) {
          assert(
            nextState is BehaviourFlag,
            "The initial state of the character must be behavioural!",
          );

          stateHistory.add(CharacterState(
            entityType: nextState.type,
            behaviour: nextState as BehaviourFlag,
            updatedAt: currentTurn,
          ));
        } else {
          final CharacterState mutated =
              prev.updatedAt == currentTurn ? prev : prev.cloneIn(currentTurn);

          switch (nextState) {
            case CurrentMentalState():
              mutated.mentalStates.addAll(nextState.mentalStates);
            case BehaviourFlag():
              mutated.behaviour = nextState;
            case SanityLevel(:final sanity):
              mutated.sanityLevel = sanity;
            case DominantMentalTrait():
            case EntityAtKeyLocation():
            case EntityActionCount():
              throw UnimplementedError();
          }

          if (mutated != prev) stateHistory.add(mutated);
        }

        if (gameEndingBehaviours.contains(nextState)) {
          shouldFastForwardAlchemist = true;
        }

        updated.add(nextState.type);
      }
    }

    if (shouldFastForwardAlchemist) {
      final lastAlchemistState = entityStates[const Alchemist()]!.last;
      final lastBehaviour = lastAlchemistState.behaviour;
      if (lastBehaviour is AlchemistTravelling) {
        final newBehaviour =
            AlchemistTravelling(AlchemistTravelling.checkpoints.lastIndex);
        if (lastAlchemistState.updatedAt == currentTurn) {
          lastAlchemistState.behaviour = newBehaviour;
        } else {
          entityStates[const Alchemist()]!.add(
            CharacterState(
              entityType: const Alchemist(),
              behaviour: newBehaviour,
            ),
          );
        }
        updated.add(const Alchemist());
      }
    }

    print(updated);
    for (final l in _listeners) {
      if (updated.contains(l.entityType)) _turnTransitionQueue.add(l);
    }
    _nextTransition(null);
  }

  void _nextTransition(EntityType? from) {
    print('$lockedBy, $from, ${_turnTransitionQueue.length}');
    if (lockedBy != null && lockedBy != from) return;
    if (_turnTransitionQueue.isEmpty) {
      lockedBy = null;
      currentTurn++;
      print(toString());
      return;
    }

    final curr = _turnTransitionQueue.removeFirst();
    lockedBy = curr.entityType;
    curr._runTurnTransition(
      entityStates[curr.entityType]!.last,
      isLast: _turnTransitionQueue.isEmpty,
    );
  }
}

bool flagsMatchPreReqs(
  Iterable<EntityFlag> flags, {
  required Iterable<EntityFlag> preReqs,
}) {
  for (final req in preReqs) {
    bool hasMatch = false;

    if (req case CurrentMentalState(:final entity, :final mentalStates)) {
      for (final other in flags) {
        if (other is! CurrentMentalState) continue;
        if (entity != other.entity) continue;

        bool allValuesMatch = true;
        for (final entry in mentalStates.entries) {
          final otherLevel = other.mentalStates[entry.key] ?? Level.none;
          if (otherLevel.index < entry.value.index) {
            allValuesMatch = false;
            break;
          }
        }

        if (allValuesMatch == true) {
          hasMatch = true;
          break;
        }
      }
    } else {
      hasMatch = flags.contains(req);
    }

    if (!hasMatch) return false;
  }

  return true;
}
