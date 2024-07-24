import 'key_locations.dart';

part 'flags.g.dart';

enum MentalState {
  normal,
  manic,
  paranoid,
  scared,
  doubtful,
  insecure,
  depressed,
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
        CurrentMentalState(:final entity, :final mentalState) =>
          '${entity}MentalState(${mentalState.name})',
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
  const CurrentMentalState(this.entity, this.mentalState, this.level);
  final T entity;
  final MentalState mentalState;
  final int level;

  @override
  bool operator ==(Object other) =>
      other is CurrentMentalState<T> && mentalState == other.mentalState;

  @override
  int get hashCode => entity.hashCode ^ mentalState.hashCode;
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
        CurrentMentalState(:final entity) => entity,
        EntityAtKeyLocation(:final entity) => entity,
      };
}
