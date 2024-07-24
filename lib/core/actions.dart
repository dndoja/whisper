part of 'state_machine.dart';

class ActionGroup {
  const ActionGroup(this.conditions, this.actions);
  final List<EntityFlag> conditions;
  final List<TurnAction> actions;
}

const Map<EntityType, List<ActionGroup>> entityAvailableOptions = {
  CrazyJoe(): [
    ActionGroup(
      [
        CurrentMentalState(CrazyJoe(), {MentalState.normal: Level.slight})
      ],
      [
        SoulWhisper(
          'Something is off with this town',
          MentalState.paranoid,
        ),
        SoulWhisper(
          'Old Bianca is sick',
          MentalState.paranoid,
        ),
        SoulWhisper(
          'Those damn kids',
          MentalState.paranoid,
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
    this.mentalState, [
    this.mentalStateLevelUp = 1,
  ]);

  final String text;
  final MentalState mentalState;
  final int mentalStateLevelUp;

  @override
  String toString() =>
      'SoulWhisper($text, +$mentalStateLevelUp ${mentalState.name})';
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
