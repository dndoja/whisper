import 'core.dart';

final characterTracker = CharacterTracker();

class CharacterTracker {
  late final GameCharacter alchemist;
  late final GameCharacter crazyJoe;
  late final GameCharacter priest;
  late final GameCharacter rolf;
  late final GameCharacter fisherman;
  late final GameCharacter astrologer;

  final Map<EntityType, GameCharacter> _byType = {};

  Iterable<GameCharacter> get allAlive =>
      _byType.values.where((c) => !c.isRemoved && !c.isRemoving && !c.isDead);

  GameCharacter<T> register<T extends EntityType>(GameCharacter<T> character) {
    switch (character.entityType) {
      case Alchemist():
        alchemist = character;
      case Fisherman():
        fisherman = character;
      case Rolf():
        rolf = character;
      case Astrologer():
        astrologer = character;
      case CrazyJoe():
        crazyJoe = character;
      case Priest():
        priest = character;
    }

    character.subscribeToGameState();

    _byType[character.entityType] = character;

    return character;
  }

  GameCharacter ofType(EntityType type) => _byType[type]!;
}
