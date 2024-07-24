part of 'state_machine.dart';

class ActionGroup {
  const ActionGroup(this.conditions, this.actions);
  final List<EntityFlag> conditions;
  final List<TurnAction> actions;
}

const Map<EntityType, List<ActionGroup>> entityAvailableOptions = {
  CrazyJoe(): [
    ActionGroup(
      [CurrentMentalState(CrazyJoe(), MentalState.normal, 1)],
      [
        SoulWhisper(
          'Something is off with this town',
          MentalState.paranoid,
          200,
        ),
        SoulWhisper(
          'Old Bianca is sick',
          MentalState.paranoid,
          10,
        ),
        SoulWhisper(
          'Those damn kids',
          MentalState.paranoid,
          5,
        ),
      ],
    ),
  ],
};

enum TurnActionType { soulWhisper, shadowyVisions }

sealed class TurnAction {
  const TurnAction();
}

class SoulWhisper extends TurnAction {
  const SoulWhisper(
    this.text,
    this.mentalState,
    this.mentalStateBoost,
  );

  final String text;
  final MentalState mentalState;
  final int mentalStateBoost;

  @override
  String toString() =>
      'SoulWhisper($text, +$mentalStateBoost ${mentalState.name})';
}

class ShadowyVisions extends TurnAction {
  const ShadowyVisions(
    this.text,
    this.mentalState,
    this.mentalStateBoost,
  );

  final String text;
  final MentalState mentalState;
  final int mentalStateBoost;

  @override
  String toString() =>
      'ShadowyVision($text, +$mentalStateBoost ${mentalState.name})';
}
