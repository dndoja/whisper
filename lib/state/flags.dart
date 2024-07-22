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

  bool get isBehavior => switch (this) {
        EntityMentalState() => false,
        _ => true,
      };

  @override
  String toString() => switch (this) {
        EntityMentalState(:final entity, :final mentalState) =>
          '${entity}MentalState(${mentalState.name})',
        _ => runtimeType.toString(),
      };
}

class EntityAtKeyLocation<T extends EntityType> extends EntityFlag<T> {
  const EntityAtKeyLocation(this.entity, this.location);
  final T entity;
  final KeyLocation location;
}

class EntityMentalState<T extends EntityType> extends EntityFlag<T> {
  const EntityMentalState(this.entity, this.mentalState);
  final T entity;
  final MentalState mentalState;

  @override
  bool operator ==(Object other) =>
      other is EntityMentalState<T> && mentalState == other.mentalState;

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
        // EntityFlag<Peasant>() => const Peasant(),
        // EntityFlag<Glowy>() => const Glowy(),
        // EntityFlag<VillageAlchemist>() => const VillageAlchemist(),
        EntityFlag<CrazyJoe>() => const CrazyJoe(),
        EntityMentalState(:final entity) => entity,
        EntityAtKeyLocation(:final entity) => entity,
      };
}
