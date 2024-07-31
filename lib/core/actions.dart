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
          'God giving him a Herculean task.',
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
          'A fake memory of everyone he knows having been killed in the war.',
          [
            StateTransition(
              [DominantMentalTrait(CrazyJoe(), MentalTrait.superstitious)],
              [CrazyJoeThinkingHeIsDead()],
            ),
            StateTransition(
              [CrazyJoeChilling()],
              // [DominantMentalTrait(CrazyJoe(), MentalTrait.zealous)],
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
          'Priest turning to Necromancy and summoning an army of undead which kills the entire village.',
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
              [CrazyJoeChilling()],
              // [DominantMentalTrait(CrazyJoe(), MentalTrait.paranoid)],
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
          'You will be poor and miserable',
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
                  {MentalTrait.greedy: Level.extremely},
                ),
              ],
              [PriestScamming()],
            ),
          ],
        ),
        VisionsOfMadness(
          "God is not pleased with the village's show of faith",
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
          'Immense necrotic powers',
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
                    MentalTrait.superstitious: Level.slightly,
                    MentalTrait.zealous: Level.slightly,
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
