part 'state.g.dart';

sealed class EntityType {
  const EntityType();
}

sealed class WorldState<T extends EntityType> {
  const WorldState();
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
  final List<WorldState> preRequisites;
  final int duration;
  final List<WorldState> next;
}

typedef $ = StateTransition;

const peasantTravelTime = 20;

const List<$> state = [
  // Peasant
  $(
    [],
    [PeasantTendingFields()],
  ),
  $(
    [PeasantTendingFields(), GlowyInFarm()],
    [PeasantFoundGlowy()],
  ),
  $(
    [PeasantTendingFields()],
    [PeasantTendingFields()],
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

  // Village Alchemist
  $(
    [],
    [VillageAlchemistInLab()],
  ),
  $(
    [GlowyInLab()],
    [VillageAlchemistStudyingGlowy()],
    duration: 10,
  ),
];
