import 'package:flutter/foundation.dart';

import 'state_machine.dart';
import 'whispers.dart';

part 'flags.g.dart';

enum MentalTrait {
  doubtful,
  fanatic,
  greedy,
  paranoid,
  superstitious,
  zealous,
  ;

  List<String> get soulWhispers => soulWhispersByTrait[this] ?? const [];
}

enum Level {
  none,
  slightly,
  moderately,
  highly,
  extremely,
}

const int attackRangeSquared = 1;
const int defaultSanity = 4;
const int visionRadiusSquared = 100;
const Map<EntityType, int> entitiesInitialSanity = {
  // CrazyJoe(): 1,
  // Priest(): 2,
};

const List<BehaviourFlag> gameEndingBehaviours = [
  CrazyJoeRampaging(),
  CrazyJoeCrusading(),
  CrazyJoeStabbingPriest(),
  PriestNecromancing(),
];

const Set<BehaviourFlag> leavingMapBehaviours = {
  CrazyJoeRunningFromZombies(),
  CrazyJoeFightingForPeace(),
  CrazyJoeRunningFromGhosts(),
};

sealed class EntityType {
  const EntityType();

  @override
  String toString() => runtimeType.toString();

  int get initialSanity => entitiesInitialSanity[this] ?? defaultSanity;

  String get animationPrefix => switch (this) {
        CrazyJoe() => 'crazy-joe',
        Priest() => 'priest',
        Fisherman() => 'fisherman',
        Astrologer() => 'astrologer',
        Rolf() => 'rolf',
        Alchemist() => 'alchemist',
      };

  String get name => switch (this) {
        CrazyJoe() => 'Crazy Joe',
        Priest() => 'Priest Abraham',
        Fisherman() => 'Fisherman Nat',
        Astrologer() => 'Maria the Astrologer',
        Rolf() => 'Rolf',
        Alchemist() => 'The Alchemist',
      };

  String get description => switch (this) {
        CrazyJoe() => 'Crazy Joe',
        Priest() => 'Priest Abraham',
        Fisherman() => 'Fisherman Nat',
        Astrologer() => 'Maria the Astrologer',
        Rolf() => 'Rolf',
        Alchemist() => 'The Alchemist',
      };
}

sealed class EntityFlag<T extends EntityType> {
  const EntityFlag();

  @override
  String toString() => switch (this) {
        CurrentMentalState(:final entity, :final mentalStates) =>
          '${entity}MentalState($mentalStates)',
        _ => runtimeType.toString(),
      };

  bool get endsInLeavingMap => leavingMapBehaviours.contains(this);
}

sealed class BehaviourFlag<T extends EntityType> extends EntityFlag<T> {
  const BehaviourFlag();
}

class AlchemistTravelling extends BehaviourFlag<Alchemist> {
  const AlchemistTravelling(this.turnCount);
  final int turnCount;

  static const List<Point16> checkpoints = [
    Point16(93, 22),
    Point16(91, 24),
    Point16(91, 29),
    Point16(91, 44),
    Point16(41, 44),
    Point16(31, 44),
    Point16(31, 22),
  ];

  @override
  String toString() => 'AlchemistTravelling($turnCount)';

  @override
  int get hashCode => const Alchemist().hashCode ^ turnCount.hashCode;

  @override
  bool operator ==(Object other) =>
      other is AlchemistTravelling && other.turnCount == turnCount;
}

class EntityActionCount<T extends EntityType> extends EntityFlag<T> {
  const EntityActionCount(this.entity, this.actionType, this.actionCount);
  final T entity;
  final TurnActionType actionType;
  final int actionCount;

  @override
  bool operator ==(Object other) =>
      other is EntityActionCount<T> &&
      entity == other.entity &&
      actionType == other.actionType &&
      actionCount == other.actionCount;

  @override
  int get hashCode => Object.hashAll([entity, actionType, actionCount]);
}

class EntityAtKeyLocation<T extends EntityType> extends EntityFlag<T> {
  const EntityAtKeyLocation(this.entity, this.location);
  final T entity;
  final KeyLocation location;
}

class CurrentMentalState<T extends EntityType> extends EntityFlag<T> {
  const CurrentMentalState(this.entity, this.mentalStates);
  final T entity;
  final Map<MentalTrait, Level> mentalStates;

  @override
  bool operator ==(Object other) =>
      other is CurrentMentalState<T> &&
      entity == other.entity &&
      mapEquals(mentalStates, other.mentalStates);

  @override
  int get hashCode => Object.hashAll([entity, mentalStates]);
}

class DominantMentalTrait<T extends EntityType> extends EntityFlag<T> {
  const DominantMentalTrait(this.entity, this.dominantTrait);
  final T entity;
  final MentalTrait dominantTrait;

  @override
  bool operator ==(Object other) =>
      other is DominantMentalTrait &&
      entity == other.entity &&
      dominantTrait == other.dominantTrait;

  @override
  int get hashCode => entity.hashCode ^ dominantTrait.hashCode;

  @override
  String toString() => 'DominantMentalTrait(${dominantTrait.name})';
}

class SanityLevel<T extends EntityType> extends EntityFlag<T> {
  const SanityLevel(this.entity, this.sanity);
  final T entity;

  /// Sanity level, 0 is the lowest (a.k.a Insane)
  final int sanity;

  @override
  bool operator ==(Object other) =>
      other is SanityLevel &&
      other.entity == other.entity &&
      other.sanity == sanity;

  @override
  int get hashCode => entity.hashCode ^ sanity.hashCode;

  @override
  String toString() => 'SanityLevel@$entity($sanity)';
}

extension EntityFlagGetType<T extends EntityType> on EntityFlag<T> {
  EntityType get type => switch (this) {
        BehaviourFlag<Alchemist>() => const Alchemist(),
        BehaviourFlag<CrazyJoe>() => const CrazyJoe(),
        BehaviourFlag<Priest>() => const Priest(),
        BehaviourFlag<Fisherman>() => const Fisherman(),
        BehaviourFlag<Astrologer>() => const Astrologer(),
        BehaviourFlag<Rolf>() => const Rolf(),
        CurrentMentalState(:final entity) => entity,
        DominantMentalTrait(:final entity) => entity,
        EntityActionCount(:final entity) => entity,
        EntityAtKeyLocation(:final entity) => entity,
        SanityLevel(:final entity) => entity,
      };
}
