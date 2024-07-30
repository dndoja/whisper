import 'package:whisper/core/core.dart';

import 'flags.dart';

const Map<EntityType, EntityDialogs> entityDialogs = {
  CrazyJoe(): EntityDialogs<CrazyJoe>(
    forBehaviours: {
      CrazyJoeCrusading(): '',
      CrazyJoeSavingKingdom(): '',
      CrazyJoeFearingDevil(): 'The Devil is real scary!',
      CrazyJoeFindingGod(): '',
      CrazyJoeRampaging(): '',
      CrazyJoeThinkingHeIsDead(): '',
      CrazyJoeRunningFromGhosts(): '',
      CrazyJoeFightingForPeace(): '',
      CrazyJoeStabbingPriest(): '',
      CrazyJoeRunningFromZombies():
          "Joe ain't dealin' with no Zombies. Y'all stay safe tho!",
      CrazyJoeRepenting(): '',
      CrazyJoeDoomsaying(): '',
    },
  ),
  Priest(): EntityDialogs<CrazyJoe>(
    forBehaviours: {
      CrazyJoeCrusading(): '',
      CrazyJoeSavingKingdom(): '',
      CrazyJoeFearingDevil(): 'The Devil is real scary!',
      CrazyJoeFindingGod(): '',
      CrazyJoeRampaging(): '',
      CrazyJoeThinkingHeIsDead(): '',
      CrazyJoeRunningFromGhosts(): '',
      CrazyJoeFightingForPeace(): '',
      CrazyJoeStabbingPriest(): '',
      CrazyJoeRunningFromZombies():
          "Joe ain't dealin' with no Zombies. Y'all stay safe tho!",
      CrazyJoeRepenting(): '',
      CrazyJoeDoomsaying(): '',
    },
  ),
};

class EntityDialogs<T extends EntityType> {
  const EntityDialogs({
    required this.forBehaviours,
    this.forMentalTraits = const {},
  });
  final Map<BehaviourFlag<T>, String> forBehaviours;
  final Map<(MentalTrait, Level), String> forMentalTraits;
}
