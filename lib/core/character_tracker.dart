import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/state_machine.dart';

import 'flags.dart';

final characterTracker = CharacterTracker();

class CharacterTracker {
  late final SimpleEnemy crazyJoe;
  late final SimpleEnemy priest;

  GameCharacter<T> register<T extends EntityType>(GameCharacter<T> character) {
    switch (character.entityType) {
      case CrazyJoe():
        crazyJoe = character;
      case PriestAbraham():
        priest = character;
    }

    return character;
  }

  SimpleEnemy ofType(EntityType type) => switch(type) {
    const CrazyJoe() => crazyJoe,
    const PriestAbraham() => priest,
    _ => throw UnimplementedError()
  };
}
