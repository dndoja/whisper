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
    $([], [
      PeasantTendingFields(),
      EntityMentalState(Peasant(), MentalState.normal),
    ]),
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
      [
        PeasantInAlchemistLab(),
        EntityMentalState(Peasant(), MentalState.manic)
      ],
      [PeasantStabsAlchemist(), VillageAlchemistIsDead()],
    ),
    $(
      [PeasantComingHome()],
      [PeasantTendingFields()],
      duration: peasantTravelTime,
    ),
  ],

  // Village Alchemist
  [
    $([], [
      VillageAlchemistInLab(),
      EntityMentalState(VillageAlchemist(), MentalState.normal),
    ]),
    $(
      [VillageAlchemistInLab(), GlowyInLab()],
      [VillageAlchemistStudyingGlowy()],
    ),
  ],
];
