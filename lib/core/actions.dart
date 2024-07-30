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
          'God giving him a Herculean task. (P+Z)',
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
                    MentalTrait.paranoid: Level.slightly,
                    MentalTrait.zealous: Level.slightly,
                  },
                )
              ],
              [CrazyJoeCrusading()],
            ),
          ],
        ),
        VisionsOfMadness(
          'A fake memory of everyone in the village having been killed in the war. (P+S)',
          [
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.superstitious)],
              [CrazyJoeThinkingHeIsDead()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.zealous)],
              [CrazyJoeFightingForPeace()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.paranoid)],
              [CrazyJoeRunningFromGhosts()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  CrazyJoe(),
                  {
                    MentalTrait.paranoid: Level.slightly,
                    MentalTrait.superstitious: Level.slightly,
                  },
                )
              ],
              [CrazyJoeRampaging()],
            ),
          ],
        ),
        VisionsOfMadness(
          'Priest turning to Necromancy and summoning an army of undead which kills the entire village. (S+Z)',
          [
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.superstitious)],
              [CrazyJoeDoomsaying()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.zealous)],
              [CrazyJoeRepenting()],
            ),
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.paranoid)],
              [CrazyJoeRunningFromZombies()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  CrazyJoe(),
                  {
                    MentalTrait.superstitious: Level.slightly,
                    MentalTrait.zealous: Level.slightly,
                  },
                )
              ],
              [CrazyJoeStabbingPriest()],
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
  Priest(): [
    ActionGroup(
      [SanityLevel(Priest(), 1)],
      [
        VisionsOfMadness(
          'Zombies',
          [
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.fanatic)],
              [PriestSummoningZombies()],
            ),
          ],
        ),
        VisionsOfMadness(
          'Poor',
          [
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.greedy)],
              [PriestScamming()],
            ),
          ],
        ),
      ],
    ),
    ActionGroup(
      [EntityActionCount(Priest(), TurnActionType.darkWhispers, 0)],
      [
        DarkWhispers(
          'Fanatic',
          MentalTrait.fanatic,
        ),
        DarkWhispers(
          'Greedy',
          MentalTrait.greedy,
        ),
        DarkWhispers(
          'Fanatic',
          MentalTrait.fanatic,
        ),
      ],
    ),
  ],
};

enum TurnActionType { darkWhispers, visionsOfMadness }

sealed class TurnAction {
  const TurnAction();

  String get name => switch (this) {
    DarkWhispers() => 'Dark Whisper',
    VisionsOfMadness() => 'Visions of Madness',
  };
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
