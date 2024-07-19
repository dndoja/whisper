part of 'state.dart';

sealed class UserAction {
  const UserAction();

  int get maxUsagesPerTurn => switch (this) {
        Shadowstep() => 1,
        SoulMirror() => 1 << 31,
        ObserverShade() => 2,
        SoulWhisper() => 1,
      };
}

class Shadowstep extends UserAction {
  const Shadowstep();

  @override
  String toString() => 'Shadowstep';
}

class SoulMirror extends UserAction {
  const SoulMirror(this.target);
  final EntityType target;

  @override
  String toString() => 'SoulMirror($target)';
}

class ObserverShade extends UserAction {
  const ObserverShade();

  @override
  String toString() => 'ObserverShade';
}

class SoulWhisper extends UserAction {
  const SoulWhisper(
    this.target,
    this.mentalState,
    this.bonus,
  );
  final EntityType target;
  final MentalState mentalState;
  final int bonus;

  @override
  String toString() => 'SoulWhisper($target, +$bonus ${mentalState.name})';
}
