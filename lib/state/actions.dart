part of 'state_machine.dart';

sealed class UserAction {
  const UserAction();

  int get maxUsagesPerTurn => switch (this) {
        ShadowStep() => 1,
        SoulMirror() => 1 << 31,
        ObserverShade() => 2,
        SoulWhisper() => 1,
      };
}

class ShadowStep extends UserAction {
  const ShadowStep();

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
