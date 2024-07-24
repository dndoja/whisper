import 'package:flutter/foundation.dart';

import 'key_locations.dart';

part 'flags.g.dart';

enum MentalTrait {
  normal,
  manic,
  paranoid,
  scared,
  doubtful,
  insecure,
  depressed,
  zealous,
}

enum Level {
  none,
  slight,
  moderate,
  major,
  extreme,
}

sealed class EntityType {
  const EntityType();

  @override
  String toString() => runtimeType.toString();
}

sealed class EntityFlag<T extends EntityType> {
  const EntityFlag();

  @override
  String toString() => switch (this) {
        CurrentMentalState(:final entity, :final mentalStates) =>
          '${entity}MentalState($mentalStates)',
        _ => runtimeType.toString(),
      };
}

sealed class BehaviourFlag<T extends EntityType> extends EntityFlag<T> {
  const BehaviourFlag();
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
      mapEquals(mentalStates, other.mentalStates);

  @override
  int get hashCode => Object.hashAll([entity, mentalStates]);
}

extension EntityTypeX on EntityType {
  static const Map<EntityType, bool> humanityMap = {
    CrazyJoe(): true,
  };

  bool get isHuman => humanityMap[this] ?? true;
}

extension EntityFlagGetType<T extends EntityType> on EntityFlag<T> {
  EntityType get type => switch (this) {
        BehaviourFlag<CrazyJoe>() => const CrazyJoe(),
        BehaviourFlag<PriestAbraham>() => const PriestAbraham(),
        CurrentMentalState(:final entity) => entity,
        EntityAtKeyLocation(:final entity) => entity,
      };
}
