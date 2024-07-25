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
      CrazyJoeLeavingVillage(): '',
      CrazyJoeFightingForPeace(): '',
      CrazyJoeStabbingPriest(): '',
      CrazyJoeRunningFromUndead(): '',
      CrazyJoeAtoneing(): '',
    },
    forMentalTraits: {
      (MentalTrait.paranoid, Level.slight): 'Slightly Paranoid',
      (MentalTrait.paranoid, Level.moderate): '',
      (MentalTrait.paranoid, Level.major): '',
      (MentalTrait.paranoid, Level.extreme): '',
      (MentalTrait.superstitious, Level.slight): '',
      (MentalTrait.superstitious, Level.moderate): '',
      (MentalTrait.superstitious, Level.major): '',
      (MentalTrait.superstitious, Level.extreme): '',
      (MentalTrait.zealous, Level.slight): '',
      (MentalTrait.zealous, Level.moderate): '',
      (MentalTrait.zealous, Level.major): '',
      (MentalTrait.zealous, Level.extreme): '',
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
