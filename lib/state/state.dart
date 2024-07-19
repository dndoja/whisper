import 'package:dartx/dartx.dart';

import 'transitions.dart';

part 'actions.dart';
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

  @override
  bool operator ==(Object other) =>
      other is EntityMentalState<T> && mentalState == other.mentalState;

  @override
  int get hashCode => entity.hashCode ^ mentalState.hashCode;
}

extension EntityTypeX on EntityType {
  static const Map<EntityType, bool> humanityMap = {
    Peasant(): true,
    Glowy(): false,
    VillageAlchemist(): true,
  };

  bool get isHuman => humanityMap[this] ?? true;
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
    required this.entityType,
    required this.physical,
    required this.updatedAt,
    Map<MentalState, int>? mentalStates,
  }) : mentalStates = mentalStates != null
            ? Map.of(mentalStates)
            : {
                for (final mentalState in MentalState.values) mentalState: 0,
                MentalState.normal: 100,
              };

  final T entityType;
  final int updatedAt;
  EntityState<T> physical;

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

  Iterable<EntityState<T>> flags() sync* {
    yield physical;
    final currentMentalState = this.currentMentalState;
    if (currentMentalState != null) yield currentMentalState;
  }
}

class GameState {
  GameState() {
    endTurn();
  }

  final Map<EntityType, List<CharacterState>> entityStates = {};
  final Map<StateTransition, int> ongoingTransitions = {};
  int currentTurn = 0;

  void endTurn([List<UserAction> turnActions = const []]) {
    for (final action in turnActions) {
      switch (action) {
        case SoulWhisper(:final target, :final mentalState, :final bonus):
          entityStates[target]!.last.boostMentalState(mentalState, bonus);
        default:
      }
    }

    final List<EntityState> currentStates = entityStates.values
        .expand<EntityState>((v) => v.lastOrNull?.flags() ?? const [])
        .toList();

    print('Turn $currentTurn');
    print('Actions: $turnActions');
    print('Current: $currentStates');

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
            entityType: nextState.type,
            physical: nextState,
            updatedAt: currentTurn,
          ));
        } else if (prev.updatedAt == currentTurn) {
          switch (nextState) {
            case EntityMentalState():
              prev.boostMentalState(nextState.mentalState);
            default:
              prev.physical = nextState;
          }
        } else {
          final newState = CharacterState(
            entityType: prev.entityType,
            mentalStates: prev.mentalStates,
            physical: prev.physical,
            updatedAt: currentTurn,
          );

          switch (nextState) {
            case EntityMentalState():
              newState.boostMentalState(nextState.mentalState);
            default:
              newState.physical = nextState;
          }

          stateHistory.add(newState);
        }
      }
    }

    currentTurn++;
  }
}
