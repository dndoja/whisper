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
        CurrentMentalState(CrazyJoe(), {MentalTrait.normal: Level.slight})
      ],
      [
        SoulWhisper(
          'Something is off with this town',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Old Bianca is sick',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Those damn kids',
          MentalTrait.paranoid,
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
  final MentalTrait mentalState;
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
  final MentalTrait mentalState;
  final int mentalStateBoost;

  @override
  String toString() =>
      'ShadowyVision($text, +$mentalStateBoost ${mentalState.name})';
}
