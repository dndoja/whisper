import 'dart:async';

import 'flags.dart';

class CharacterTapManager {
  CharacterTapManager._();

  static final CharacterTapManager $ = CharacterTapManager._();

  final List<Function(EntityType)> _listeners = [];
  final List<Completer<EntityType>> _completers = [];
  bool get waitingForTaps => _completers.isNotEmpty;

  void addListener(Function(EntityType) listener) => _listeners.add(listener);

  void removeListener(Function(EntityType) listener) =>
      _listeners.remove(listener);

  Future<EntityType> waitForTap() {
    final Completer<EntityType> completer = Completer();
    _completers.add(completer);
    return completer.future;
  }

  void onTap(EntityType character) {
    for (final l in CharacterTapManager.$._listeners) {
      l.call(character);
    }

    for (final c in _completers) {
      c.complete(character);
    }

    _completers.clear();
  }
}
