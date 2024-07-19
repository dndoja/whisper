import 'package:dartx/dartx.dart';

part 'state.g.dart';

sealed class EntityType {
  const EntityType();

  @override
  String toString() => runtimeType.toString();
}

sealed class EntityState<T extends EntityType> {
  const EntityState();

  @override
  String toString() => runtimeType.toString();
}

extension EntityStateGetType<T extends EntityType> on EntityState<T> {
  EntityType get type => switch (this) {
        EntityState<Peasant>() => const Peasant(),
        EntityState<Glowy>() => const Glowy(),
        EntityState<VillageAlchemist>() => const VillageAlchemist(),
      };
}

enum NegativeEmotionalState {
  manic,
  paranoid,
  scared,
  doubtful,
  insecure,
  depressed,
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

typedef $ = StateTransition;

const peasantTravelTime = 3;

const List<List<StateTransition>> stateTransitions = [
  // Glowy
  [
    $([], [GlowyInFarm()]),
  ],

  // Peasant
  [
    $([], [PeasantTendingFields()]),
    $(
      [PeasantTendingFields(), GlowyInFarm()],
      [PeasantFoundGlowy()],
    ),
    $(
      [PeasantFoundGlowy()],
      [PeasantGoingToAlchemistLab()],
    ),
    $(
      [PeasantGoingToAlchemistLab()],
      [PeasantInAlchemistLab()],
      duration: peasantTravelTime,
    ),
    $(
      [PeasantInAlchemistLab()],
      [PeasantComingHome(), GlowyInLab()],
    ),
    $(
      [PeasantComingHome()],
      [PeasantTendingFields()],
      duration: peasantTravelTime,
    ),
  ],

  // Village Alchemist
  [
    $([], [VillageAlchemistInLab()]),
    $(
      [VillageAlchemistInLab(), GlowyInLab()],
      [VillageAlchemistStudyingGlowy()],
    ),
  ],
];

class GameState {
  GameState() {
    nextTurn();
  }

  final Map<EntityType, (EntityState?, EntityState)> entityStates = {};
  final Map<StateTransition, int> ongoingTransitions = {};
  int currentTurn = 0;

  void nextTurn() {
    final List<EntityState> startingStates =
        entityStates.values.map((v) => v.$2).toList();

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
        final prev = entityStates[nextState.type]?.$2;
        entityStates[nextState.type] = (prev, nextState);
      }
    }

    currentTurn++;
  }
}
