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
    required this.behavior,
    this.updatedAt = 0,
    Map<MentalState, int>? mentalStates,
  }) : mentalStates = mentalStates != null
            ? Map.of(mentalStates)
            : {
                for (final mentalState in MentalState.values) mentalState: 0,
                MentalState.normal: 100,
              };

  final T entityType;
  final int updatedAt;
  EntityFlag<T> behavior;

  final Map<MentalState, int> mentalStates;
  EntityMentalState<T>? get currentMentalState => entityType.isHuman
      ? EntityMentalState(
          entityType,
          mentalStates.entries.maxBy((e) => e.value)!.key,
        )
      : null;

  void boostMentalState(MentalState mentalState, [int? amount]) {
    if (amount == null) {
      final max = mentalStates.entries.maxBy((e) => e.value)!;
      if (max.key != mentalState) mentalStates[mentalState] = max.value + 1;
    } else {
      final int curr = mentalStates[mentalState] ?? 0;
      mentalStates[mentalState] = curr + amount;
    }
  }

  Iterable<EntityFlag<T>> flags() sync* {
    yield behavior;
    final currentMentalState = this.currentMentalState;
    if (currentMentalState != null) yield currentMentalState;
  }
}

mixin GameCharacter<T extends EntityType> {
  T get character;

  void subscribeToGameState(GameState gameState) {
    gameState._listeners.add(this);
  }

  void onStateChange(CharacterState<T> newState);
}

class GameState {
  GameState() {
    endTurn();
  }

  final Map<EntityType, List<CharacterState>> entityStates = {};
  final Map<StateTransition, int> ongoingTransitions = {};

  final List<GameCharacter> _listeners = [];

  int currentTurn = 0;

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
          state.behavior.toString().removePrefix(name).decapitalize();
      buffer
        ..write(entityType.toString())
        ..write(': $physicalState');
      if (entityType.isHuman) {
        buffer.write(', ${state.currentMentalState?.mentalState.name}');
      }

      buffer.write(' (mut: ${state.updatedAt})');
      buffer.writeln();
    }

    return buffer.toString();
  }

  void endTurn([List<UserAction> turnActions = const []]) {
    for (final action in turnActions) {
      switch (action) {
        case SoulWhisper(:final target, :final mentalState, :final bonus):
          entityStates[target]!.last.boostMentalState(mentalState, bonus);
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
            nextState.isBehavior,
            "The initial state of the character must be physical!",
          );

          stateHistory.add(CharacterState(
            entityType: nextState.type,
            behavior: nextState,
            updatedAt: currentTurn,
          ));
        } else if (prev.updatedAt == currentTurn) {
          switch (nextState) {
            case EntityMentalState():
              prev.boostMentalState(nextState.mentalState);
            default:
              prev.behavior = nextState;
          }
        } else {
          final newState = CharacterState(
            entityType: prev.entityType,
            mentalStates: prev.mentalStates,
            behavior: prev.behavior,
            updatedAt: currentTurn,
          );

          switch (nextState) {
            case EntityMentalState():
              newState.boostMentalState(nextState.mentalState);
            default:
              newState.behavior = nextState;
          }

          stateHistory.add(newState);
        }

        updated.add(nextState.type);
      }
    }

    currentTurn++;

    for (final listener in _listeners) {
      if (updated.contains(listener.character)) {
        listener.onStateChange(entityStates[listener.character]!.last);
      }
    }
  }
}
