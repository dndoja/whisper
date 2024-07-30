import 'package:whisper/core/core.dart';

import 'flags.dart';

const Map<EntityType, EntityDialogs> entityDialogs = {
  CrazyJoe(): EntityDialogs<CrazyJoe>(),
  Priest(): EntityDialogs<CrazyJoe>(),
};

class EntityDialogs<T extends EntityType> {
  const EntityDialogs({
    this.forBehaviours = const {},
    this.forMentalTraits = const {},
  });
  final Map<BehaviourFlag<T>, String> forBehaviours;
  final Map<(MentalTrait, Level), String> forMentalTraits;
}
