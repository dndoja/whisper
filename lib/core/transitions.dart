import 'core.dart';

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
    $([], [PriestPraying()]),
  ],
  [
    $([], [AstrologerObserving()]),
  ],
  [
    $([], [RolfRolfing()]),
  ],
  [
    $([], [FishermanFishing()]),
  ],
];
