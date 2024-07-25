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
