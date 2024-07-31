part of 'state_machine.dart';

class ActionGroup {
  const ActionGroup(this.conditions, this.actions);
  final List<EntityFlag> conditions;
  final List<TurnAction> actions;
}

final Set<BehaviourFlag> possibleFinalOutcomes = {
  const AlchemistBuyingDefectiveHolyWater(),
  const AlchemistPerformingExperiment(),
  for (final bigGroup in entityAvailableOptions.values)
    for (final group in bigGroup)
      for (final action in group.actions)
        if (action case VisionsOfMadness(:final transitions))
          for (final transition in transitions)
            for (final flag in transition.next)
              if (flag is BehaviourFlag) flag,
};

const Map<EntityType, List<ActionGroup>> entityAvailableOptions = {
  CrazyJoe(): [
    ActionGroup(
      [SanityLevel(CrazyJoe(), 1)],
      [
        VisionsOfMadness(
          'A Herculean Task, handed to you by God himself',
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
                    MentalTrait.zealous: Level.moderately,
                    MentalTrait.paranoid: Level.slightly,
                  },
                )
              ],
              [CrazyJoeCrusading()],
            ),
          ],
        ),
        VisionsOfMadness(
          'A fake memory where everyone in the village has been killed in the war.',
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
                    MentalTrait.paranoid: Level.moderately,
                    MentalTrait.superstitious: Level.slightly,
                  },
                )
              ],
              [CrazyJoeRampaging()],
            ),
          ],
        ),
        VisionsOfMadness(
          'The Priest turning to Necromancy and summoning an army of undead which kills the entire village.',
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
                    MentalTrait.superstitious: Level.moderately,
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
      [],
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
          'A lookahead into a poor and miserable future',
          [
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.fanatic)],
              [PriestUpholdingGodsWill()],
            ),
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.doubtful)],
              [PriestUpholdingGodsWill()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  Priest(),
                  {MentalTrait.greedy: Level.slightly},
                ),
              ],
              [PriestHustling()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  Priest(),
                  {MentalTrait.greedy: Level.highly},
                ),
              ],
              [PriestScamming()],
            ),
          ],
        ),
        VisionsOfMadness(
          "A dissappointed God",
          [
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.fanatic)],
              [PriestSelfFlagellating()],
            ),
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.doubtful)],
              [PriestRediscoveringFaith()],
            ),
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.greedy)],
              [PriestAskingForIndulgences(), AstrologerMockingPriest()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  Priest(),
                  {
                    MentalTrait.greedy: Level.slightly,
                    MentalTrait.fanatic: Level.moderately,
                  },
                ),
              ],
              [FishermanHuntingPriest(), PriestThreateningInquisition()],
            ),
          ],
        ),
        VisionsOfMadness(
          'World Domination, through immense Necrotic powers',
          [
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.fanatic)],
              [PriestRidiculingNecromancy()],
            ),
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.doubtful)],
              [PriestSelfPitying()],
            ),
            StateTransition(
              [DominantMentalTrait(Priest(), MentalTrait.greedy)],
              [PriestAbolishingGreed()],
            ),
            StateTransition(
              [
                CurrentMentalState(
                  Priest(),
                  {
                    MentalTrait.fanatic: Level.moderately,
                    MentalTrait.doubtful: Level.slightly,
                  },
                )
              ],
              [PriestNecromancing()],
            ),
          ],
        ),
      ],
    ),
    ActionGroup(
      [],
      [
        DarkWhispers(
          'Doubtful',
          MentalTrait.doubtful,
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
