import 'core.dart';

typedef $ = StateTransition;

const int peasantTravelTime = 3;

const Map<EntityType, String> soulMirrorMessages = {};

const List<List<StateTransition>> stateTransitions = [
  // Crazy Joe
  [
    $([], [CrazyJoeChilling()]),
  ],
  // Priest Abraham
  [
    $([], [PriestPraying()]),
  ],
  [
    $([], [AstrologerObserving()]),
    $([AstrologerMockingPriest()], [AstrologerObserving()]),
  ],
  [
    $([], [RolfRolfing()]),
  ],
  [
    $([], [FishermanFishing()]),
  ],
  [
    $([], [AlchemistIdle()]),
    $([AlchemistIdle()], [AlchemistExplainingMasterPlan()]),
    $([AlchemistExplainingMasterPlan()], [AlchemistTravelling(0)]),
    $([AlchemistTravelling(0)], [AlchemistTravelling(1)]),
    $([AlchemistTravelling(1)], [AlchemistTravelling(2)]),
    $([AlchemistTravelling(2)], [AlchemistTravelling(3)]),
    $([AlchemistTravelling(3)], [AlchemistTravelling(4)]),
    $([AlchemistTravelling(4)], [AlchemistTravelling(5)]),
    $([AlchemistTravelling(5)], [AlchemistTravelling(6)]),
    $([AlchemistTravelling(6)], [AlchemistPickingUpBones()]),
    // $([AlchemistTravelling(6)], [AlchemistTravelling(7)]),
    $([AlchemistPickingUpBones()], [AlchemistPickingUpHolyWater()]),
    $(
      [AlchemistPickingUpBones(), PriestScamming()],
      [AlchemistBuyingDefectiveHolyWater()],
    ),
    $(
      [AlchemistPickingUpBones(), PriestHustling()],
      [AlchemistBuyingOverpricedHolyWater()],
    ),
    $(
      [AlchemistBuyingOverpricedHolyWater()],
      [AlchemistPickingUpAstrologyTips()],
    ),
    $(
      [AlchemistBuyingDefectiveHolyWater()],
      [AlchemistPickingUpAstrologyTips()],
    ),
    $([AlchemistPickingUpHolyWater()], [AlchemistPickingUpAstrologyTips()]),
    $([AlchemistPickingUpAstrologyTips()], [AlchemistPerformingExperiment()]),
  ],
];
