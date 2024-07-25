part of 'state_machine.dart';

class ActionGroup {
  const ActionGroup(this.conditions, this.actions);
  final List<EntityFlag> conditions;
  final List<TurnAction> actions;
}

const Map<EntityType, List<ActionGroup>> entityAvailableOptions = {
  CrazyJoe(): [
    ActionGroup(
      [SanityLevel(CrazyJoe(), 1)],
      [
        SurrenderToMadness(
          'God speaks to Joe, letting him know that he is his strongest soldier.',
          [
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.superstitious)],
              [CrazyJoeFindingGod()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.zealous)],
              [CrazyJoeSavingKingdom()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.paranoid)],
              [CrazyJoeFearingDevil()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  CrazyJoe(),
                  {
                    MentalTrait.paranoid: Level.slight,
                    MentalTrait.zealous: Level.slight,
                  },
                )
              ],
              [CrazyJoeCrusading()],
            ),
          ],
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 0)],
      [
        SoulWhisper(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Zealous',
          MentalTrait.zealous,
        ),
        SoulWhisper(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 1)],
      [
        SoulWhisper(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Zealous',
          MentalTrait.zealous,
        ),
        SoulWhisper(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 2)],
      [
        SoulWhisper(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Zealous',
          MentalTrait.zealous,
        ),
        SoulWhisper(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 3)],
      [
        SoulWhisper(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Zealous',
          MentalTrait.zealous,
        ),
        SoulWhisper(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.soulWhisper, 4)],
      [
        SoulWhisper(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        SoulWhisper(
          'Zealous',
          MentalTrait.zealous,
        ),
        SoulWhisper(
          'Superstitious',
          MentalTrait.superstitious,
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

class SurrenderToMadness extends TurnAction {
  const SurrenderToMadness(this.text, this.transitions);
  final String text;
  final List<StateTransition> transitions;

  @override
  String toString() => 'SurrenderToMadness($text)';
}
