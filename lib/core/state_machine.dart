import 'dart:collection';
import 'dart:math' as math;

import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';

import 'flags.dart';
import 'transitions.dart';

export 'key_locations.dart';

part 'actions.dart';

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
    this.updatedAt = 0,
    int? sanityLevel,
    Map<MentalTrait, Level>? mentalStates,
  })  : mentalStates = mentalStates != null
            ? Map.of(mentalStates)
            : {MentalTrait.normal: Level.slight},
        sanityLevel = sanityLevel ?? entityType.initialSanity;

  final T entityType;
  final int updatedAt;

  int sanityLevel;
  int soulWhisperCount = 0;
  BehaviourFlag<T> behaviour;

  final Map<MentalTrait, Level> mentalStates;

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
    yield behaviour;
    yield CurrentMentalState(entityType, mentalStates);
    yield SanityLevel(entityType, sanityLevel);
    yield EntityActionCount(
      entityType,
      TurnActionType.soulWhisper,
      soulWhisperCount,
    );
  }
}

mixin GameCharacter<T extends EntityType> on SimpleEnemy {
  bool get transitioningToNewTurn;
  set transitioningToNewTurn(bool _);

  T get character;

  void onStateChange(CharacterState newState);

  void turnTransitionStart() {
    transitioningToNewTurn = true;
    gameRef.camera.follow(this);
  }

  void turnTransitionEnd() {
    if (!transitioningToNewTurn) return;
    GameState.$._nextTransition(character);
    transitioningToNewTurn = false;
    gameRef.camera.follow(gameRef.query<SimplePlayer>().first);
  }

  void subscribeToGameState() => GameState.$._listeners.add(this);
}

class GameState {
  GameState() {
    endTurn();
  }

  static final GameState $ = GameState();

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
        ..write(' (mut: ${state.updatedAt})')
        ..writeln();
    }

    return buffer.toString();
  }

  Iterable<TurnAction> availableActionsFor(EntityType entity) sync* {
    final Iterable<EntityFlag> currFlags =
        entityStates[entity]?.lastOrNull?.flags() ?? const [];
    final List<ActionGroup> actionGroups = entityAvailableOptions[entity] ?? [];

    for (final group in actionGroups) {
      if (currFlags.containsAll(group.conditions)) yield* group.actions;
    }
  }

  CharacterState ofCharacter(EntityType entity) => entityStates[entity]!.last;

  void endTurn([Map<EntityType, TurnAction> turnActions = const {}]) {
    if (lockedBy != null || isPaused) return;

   for (final entry in turnActions.entries) {
      final target = entry.key;
      switch (entry.value) {
        case SoulWhisper(
            :final mentalState,
            :final mentalStateLevelIncrease,
            :final sanityDamage,
          ):
          final state = entityStates[target]!.last;
          state
            ..boostMentalState(mentalState, mentalStateLevelIncrease)
            ..soulWhisperCount += 1
            // SoulWhisper cannot reduce Sanity below 1
            ..sanityLevel = math.max(1, state.sanityLevel - sanityDamage);

        default:
      }
    }

    final List<EntityFlag> currentStates = entityStates.values
        .expand<EntityFlag>((v) => v.lastOrNull?.flags() ?? const [])
        .toList();

    final List<StateTransition> stagedTransitions = [];
    for (final group in stateTransitions) {
      for (final transition in group.reversed) {
        if (transition.preRequisites.isEmpty && currentTurn > 0) continue;

        if (currentStates.containsAll(transition.preRequisites)) {
          stagedTransitions.add(transition);
          break;
        }
      }
    }

    final Set<EntityType> updated = {};

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
          final CharacterState mutated = prev.updatedAt == currentTurn
              ? prev
              : CharacterState(
                  entityType: prev.entityType,
                  mentalStates: prev.mentalStates,
                  behaviour: prev.behaviour,
                  updatedAt: currentTurn,
                );

          switch (nextState) {
            case CurrentMentalState():
              mutated.mentalStates.addAll(nextState.mentalStates);
            case BehaviourFlag():
              mutated.behaviour = nextState;
            case SanityLevel(:final sanity):
              mutated.sanityLevel = sanity;
            case EntityAtKeyLocation():
            case EntityActionCount():
              throw UnimplementedError();
          }

          if (mutated != prev) stateHistory.add(mutated);
        }

        updated.add(nextState.type);
      }
    }

    print(updated);
    for (final l in _listeners) {
      if (updated.contains(l.character)) _turnTransitionQueue.add(l);
    }
    _nextTransition(null);
  }

  void _nextTransition(EntityType? from) {
    // print('$lockedBy, $from, ${_turnTransitionQueue.length}');
    if (lockedBy != null && lockedBy != from) return;
    if (_turnTransitionQueue.isEmpty) {
      lockedBy = null;
      currentTurn++;
      print(toString());
      return;
    }

    final curr = _turnTransitionQueue.removeFirst();
    curr.onStateChange(entityStates[curr.character]!.last);
    lockedBy = curr.character;
  }

  void notify<T extends EntityType>(
    GameCharacter<T> char,
    CharacterState state,
  ) {
    assert(
      state is CharacterState<T>,
      'Wrong state type passed to character of type $T, found ${state.runtimeType}',
    );

    char.onStateChange(state as CharacterState<T>);
  }
}
