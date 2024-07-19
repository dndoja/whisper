import 'package:dartx/dartx.dart';

import 'transitions.dart';

part 'state.g.dart';

enum MentalState {
  normal,
  manic,
  paranoid,
  scared,
  doubtful,
  insecure,
  depressed,
}

sealed class EntityType {
  const EntityType();

  @override
  String toString() => runtimeType.toString();
}

sealed class EntityState<T extends EntityType> {
  const EntityState();

  bool get isPhysical => switch (this) {
        EntityMentalState() => false,
        _ => true,
      };

  @override
  String toString() => switch (this) {
        EntityMentalState(:final entity, :final mentalState) =>
          '${entity}MentalState(${mentalState.name})',
        _ => runtimeType.toString(),
      };
}

class EntityMentalState<T extends EntityType> extends EntityState<T> {
  const EntityMentalState(this.entity, this.mentalState);
  final T entity;
  final MentalState mentalState;
}

extension EntityStateGetType<T extends EntityType> on EntityState<T> {
  EntityType get type => switch (this) {
        EntityState<Peasant>() => const Peasant(),
        EntityState<Glowy>() => const Glowy(),
        EntityState<VillageAlchemist>() => const VillageAlchemist(),
        EntityMentalState(:final entity) => entity,
      };
}

class StateTransition {
  const StateTransition(
    this.preRequisites,
    this.next, {
    this.duration = 1,
  });
  final List<EntityState> preRequisites;
  final int duration;
  final List<EntityState> next;

  @override
  String toString() => '$preRequisites -> $next ($duration)';
}

class CharacterState<T extends EntityType> {
  CharacterState({
    required this.physical,
    this.mental,
    required this.updatedAt,
  });
  final int updatedAt;
  EntityState<T> physical;
  EntityMentalState<T>? mental;

  Iterable<EntityState<T>> flags() sync* {
    yield physical;
    if (mental != null) yield mental!;
  }
}

class GameState {
  GameState() {
    nextTurn();
  }

  final Map<EntityType, List<CharacterState>> entityStates = {};
  final Map<StateTransition, int> ongoingTransitions = {};
  int currentTurn = 0;

  void nextTurn() {
    final List<EntityState> startingStates = entityStates.values
        .expand<EntityState>((v) => v.lastOrNull?.flags() ?? const [])
        .toList();

    print('Turn $currentTurn: $startingStates');

    final List<StateTransition> stagedTransitions = [];
    for (final group in stateTransitions) {
      for (final transition in group.reversed) {
        if (transition.preRequisites.isEmpty && currentTurn > 0) continue;

        if (startingStates.containsAll(transition.preRequisites)) {
          stagedTransitions.add(transition);
          break;
        }
      }
    }

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
            nextState.isPhysical,
            "The initial state of the character must be physical!",
          );

          stateHistory.add(CharacterState(
            physical: nextState,
            updatedAt: currentTurn,
          ));
        } else if (prev.updatedAt == currentTurn) {
          switch (nextState) {
            case EntityMentalState():
              prev.mental = nextState;
            default:
              prev.physical = nextState;
          }
        } else {
          final newState = CharacterState(
            physical: prev.physical,
            mental: prev.mental,
            updatedAt: currentTurn,
          );

          switch (nextState) {
            case EntityMentalState():
              prev.mental = nextState;
            default:
              prev.physical = nextState;
          }

          stateHistory.add(newState);
        }
      }
    }

    currentTurn++;
  }
}
