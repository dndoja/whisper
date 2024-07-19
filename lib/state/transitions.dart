import 'state.dart';

typedef $ = StateTransition;

const int peasantTravelTime = 3;

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
