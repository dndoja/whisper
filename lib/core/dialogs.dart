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
      CrazyJoeRunningFromZombies(): "Joe ain't dealin' with no Zombies. Y'all stay safe tho!",
      CrazyJoeRepenting(): '',
      CrazyJoeDoomsaying(): '',
    },
    forMentalTraits: {
      (MentalTrait.paranoid, Level.slightly): 'Slightly Paranoid',
      (MentalTrait.paranoid, Level.moderately): '',
      (MentalTrait.paranoid, Level.highly): '',
      (MentalTrait.paranoid, Level.extremely): '',
      (MentalTrait.superstitious, Level.slightly): '',
      (MentalTrait.superstitious, Level.moderately): '',
      (MentalTrait.superstitious, Level.highly): '',
      (MentalTrait.superstitious, Level.extremely): '',
      (MentalTrait.zealous, Level.slightly): '',
      (MentalTrait.zealous, Level.moderately): '',
      (MentalTrait.zealous, Level.highly): '',
      (MentalTrait.zealous, Level.extremely): '',
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
      CrazyJoeRunningFromZombies(): "Joe ain't dealin' with no Zombies. Y'all stay safe tho!",
      CrazyJoeRepenting(): '',
      CrazyJoeDoomsaying(): '',
    },
    forMentalTraits: {
      (MentalTrait.paranoid, Level.slightly): 'Slightly Paranoid',
      (MentalTrait.paranoid, Level.moderately): '',
      (MentalTrait.paranoid, Level.highly): '',
      (MentalTrait.paranoid, Level.extremely): '',
      (MentalTrait.superstitious, Level.slightly): '',
      (MentalTrait.superstitious, Level.moderately): '',
      (MentalTrait.superstitious, Level.highly): '',
      (MentalTrait.superstitious, Level.extremely): '',
      (MentalTrait.zealous, Level.slightly): '',
      (MentalTrait.zealous, Level.moderately): '',
      (MentalTrait.zealous, Level.highly): '',
      (MentalTrait.zealous, Level.extremely): '',
    },
  ),
};

class EntityDialogs<T extends EntityType> {
  const EntityDialogs({
    required this.forBehaviours,
    required this.forMentalTraits,
  });
  final Map<BehaviourFlag<T>, String> forBehaviours;
  final Map<(MentalTrait, Level), String> forMentalTraits;
}
