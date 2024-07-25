import 'flags.dart';
import 'state_machine.dart';

typedef $ = StateTransition;

const int peasantTravelTime = 3;

const Map<EntityType, String> soulMirrorMessages = {};

const List<List<StateTransition>> stateTransitions = [
  // Crazy Joe
  [
    $([], [CrazyJoeChilling()]),
  ],
  // Priest Abraham
  [
    $([], [PriestAbrahamChilling()]),
  ],
];

const List<int> mentalStateCheckpoints = [100, 130, 160, 180, 200];

// const List<List<StateTransition>> stateTransitions = [
//   // Glowy
//   [
//     $([], [GlowyInFarm()]),
//   ],
//
//   // Peasant
//   [
//     $([], [PeasantTendingFields()]),
//     $(
//       [PeasantTendingFields(), GlowyInFarm()],
//       [PeasantFoundGlowy()],
//     ),
//     $(
//       [PeasantFoundGlowy()],
//       [PeasantGoingToAlchemistLab(), GlowyWithPeasant()],
//     ),
//     $(
//       [PeasantGoingToAlchemistLab()],
//       [PeasantInAlchemistLab()],
//       duration: peasantTravelTime,
//     ),
//     $(
//       [PeasantInAlchemistLab()],
//       [PeasantComingHome(), GlowyWithVillageAlchemist()],
//     ),
//     $(
//       [
//         PeasantInAlchemistLab(),
//         EntityMentalState(Peasant(), MentalState.manic),
//       ],
//       [PeasantSmashesFlaskInAlchemistHead(), VillageAlchemistIsDead()],
//     ),
//     $(
//       [PeasantSmashesFlaskInAlchemistHead()],
//       [PeasantComingHome()],
//     ),
//     $(
//       [PeasantComingHome()],
//       [PeasantTendingFields()],
//       duration: peasantTravelTime,
//     ),
//   ],
//
//   // Village Alchemist
//   [
//     $([], [VillageAlchemistInLab()]),
//     $(
//       [VillageAlchemistInLab(), GlowyWithVillageAlchemist()],
//       [VillageAlchemistStudyingGlowy()],
//     ),
//   ],
// ];
