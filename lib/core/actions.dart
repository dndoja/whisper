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
        VisionsOfMadness(
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
      [EntityActionCount(CrazyJoe(), TurnActionType.darkWhispers, 0)],
      [
        DarkWhispers(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        DarkWhispers(
          'Zealous',
          MentalTrait.zealous,
        ),
        DarkWhispers(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.darkWhispers, 1)],
      [
        DarkWhispers(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        DarkWhispers(
          'Zealous',
          MentalTrait.zealous,
        ),
        DarkWhispers(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.darkWhispers, 2)],
      [
        DarkWhispers(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        DarkWhispers(
          'Zealous',
          MentalTrait.zealous,
        ),
        DarkWhispers(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.darkWhispers, 3)],
      [
        DarkWhispers(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        DarkWhispers(
          'Zealous',
          MentalTrait.zealous,
        ),
        DarkWhispers(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(CrazyJoe(), TurnActionType.darkWhispers, 4)],
      [
        DarkWhispers(
          'Paranoid',
          MentalTrait.paranoid,
        ),
        DarkWhispers(
          'Zealous',
          MentalTrait.zealous,
        ),
        DarkWhispers(
          'Superstitious',
          MentalTrait.superstitious,
        ),
      ],
    ),
  ],
};

enum TurnActionType { darkWhispers, visionsOfMadness }

sealed class TurnAction {
  const TurnAction();
}

class DarkWhispers extends TurnAction {
  const DarkWhispers(
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
      'DarkWhisper($text, +$mentalStateLevelIncrease ${mentalState.name}, -$sanityDamage sanity)';
}

class VisionsOfMadness extends TurnAction {
  const VisionsOfMadness(this.text, this.transitions);
  final String text;
  final List<StateTransition> transitions;

  @override
  String toString() => 'SurrenderToMadness($text)';
}
