part of 'state_machine.dart';

class ActionGroup {
  const ActionGroup(this.conditions, this.actions);
  final List<EntityFlag> conditions;
  final List<TurnAction> actions;
}

const Map<EntityType, List<ActionGroup>> entityAvailableOptions = {
  CrazyJoe(): [
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 0)],
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
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 1)],
      [
        SoulWhisper(
          'Bigongon',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Bonognognog',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Rocbaidboa ndoasd i oai sjdsak dj',
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
    this.mentalState, {
    this.mentalStateLevelIncrease = 1,
    this.sanityDamage = 1,
  });

  final String text;
  final MentalTrait mentalState;
  final int mentalStateLevelIncrease;
  final int sanityDamage;

  @override
  String toString() =>
      'SoulWhisper($text, +$mentalStateLevelIncrease ${mentalState.name}, -$sanityDamage sanity)';
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
