import 'package:bonfire/bonfire.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whisper/core/core.dart';

class ShadowyTendrilsTarget {
  const ShadowyTendrilsTarget(
    this.target, {
    required this.availableVisionsOfMadness,
    required this.availableDarkWhispers,
  });

  final EntityType target;
  final List<VisionsOfMadness> availableVisionsOfMadness;
  final List<DarkWhispers> availableDarkWhispers;
}

class BottomPanel extends StatefulWidget {
  const BottomPanel(this.gameRef, {super.key});
  final BonfireGame gameRef;

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  final List<GameCharacter> shadowstepTargets = [];
  Map<EntityType, TurnAction> turnActions = {};

  ShadowyTendrilsTarget? tendrilsTarget;
  TurnActionType? selectedActionType;

  bool get canCastDarkWhispers =>
      tendrilsTarget?.availableDarkWhispers.isNotEmpty == true;

  bool get canCastVisionsOfMadness =>
      tendrilsTarget?.availableVisionsOfMadness.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyPressed);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyPressed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Turn: ${gameState.currentTurn}',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            if (tendrilsTarget != null)
              Align(
                alignment: Alignment.centerLeft,
                child: ShadowyTendrilsWidget(tendrilsTarget!.target),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedActionType == TurnActionType.darkWhispers)
                    SoulWhisperWidget(
                      options: tendrilsTarget!.availableDarkWhispers,
                      onPicked: finishOptionPicking,
                    )
                  else if (selectedActionType ==
                      TurnActionType.visionsOfMadness)
                    ShadowyVisionsWidget(
                      options: tendrilsTarget!.availableVisionsOfMadness,
                      onPicked: finishOptionPicking,
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 80,
                        width: 400,
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ActionButton('1', onTap: shadowstep),
                            const SizedBox(width: 32),
                            ActionButton('2', onTap: shadowyTendrils),
                            const SizedBox(width: 32),
                            ActionButton(
                              '3',
                              onTap: canCastDarkWhispers
                                  ? darkWhispersStart
                                  : null,
                            ),
                            const SizedBox(width: 32),
                            ActionButton(
                              '4',
                              onTap: canCastVisionsOfMadness
                                  ? visionsOfMadnessStart
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: endTurn,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          height: 70,
                          width: 70,
                          child: const Icon(Icons.arrow_right),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  void endTurn() {
    setState(() {
      gameState.endTurn(turnActions);
      turnActions = {};
    });

    final Iterable<(EntityType, String)> dialogs = gameState.characterDialogs();

    if (dialogs.none((d) => d.$2.isNotEmpty)) return;

    // TalkDialog.show(
    //   context,
    //   [
    //     for (final (_, dialog) in dialogs) Say(text: [TextSpan(text: dialog)]),
    //   ],
    // );
  }

  bool _onKeyPressed(KeyEvent event) {
    if (event is! KeyUpEvent) return false;

    final List<TurnAction> currentActions = switch (selectedActionType) {
      TurnActionType.darkWhispers =>
        tendrilsTarget?.availableDarkWhispers ?? const [],
      TurnActionType.visionsOfMadness =>
        tendrilsTarget?.availableVisionsOfMadness ?? const [],
      _ => const []
    };

    if (currentActions.isNotEmpty) {
      final int index = -1 +
          switch (event.logicalKey) {
            LogicalKeyboardKey.digit0 => 0,
            LogicalKeyboardKey.digit1 => 1,
            LogicalKeyboardKey.digit2 => 2,
            LogicalKeyboardKey.digit3 => 3,
            LogicalKeyboardKey.digit4 => 4,
            LogicalKeyboardKey.digit5 => 5,
            LogicalKeyboardKey.digit6 => 6,
            LogicalKeyboardKey.digit7 => 7,
            LogicalKeyboardKey.digit8 => 8,
            LogicalKeyboardKey.digit9 => 9,
            LogicalKeyboardKey.numpad0 => 0,
            LogicalKeyboardKey.numpad1 => 1,
            LogicalKeyboardKey.numpad2 => 2,
            LogicalKeyboardKey.numpad3 => 3,
            LogicalKeyboardKey.numpad4 => 4,
            LogicalKeyboardKey.numpad5 => 5,
            LogicalKeyboardKey.numpad6 => 6,
            LogicalKeyboardKey.numpad7 => 7,
            LogicalKeyboardKey.numpad8 => 8,
            LogicalKeyboardKey.numpad9 => 9,
            _ => 0,
          };

      if (index >= 0 && index < currentActions.length) {
        finishOptionPicking(currentActions[index]);
        return true;
      }

      return false;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.digit1:
        shadowstep();
      case LogicalKeyboardKey.digit2:
        shadowyTendrils();
      case LogicalKeyboardKey.digit3:
        darkWhispersStart();
      case LogicalKeyboardKey.digit4:
        visionsOfMadnessStart();
      default:
        return false;
    }

    return true;
  }

  void shadowstep() {
    gameState.isPaused = true;

    if (shadowstepTargets.isEmpty) {
      final Iterable<GameCharacter> enemies =
          widget.gameRef.query<GameCharacter>().where((e) => !e.isRemoved);
      if (enemies.isEmpty) return;
      shadowstepTargets.addAll(enemies);
    }

    final player = widget.gameRef.player!;
    int nextTargetIndex = 0;
    double distanceToTarget = -1;

    for (int i = 0; i < shadowstepTargets.length; i++) {
      final SimpleEnemy target = shadowstepTargets[i];
      final double distance = target.distance(player);
      if (distance < distanceToTarget) {
        nextTargetIndex = i;
        distanceToTarget = distance;
      }
    }

    final GameCharacter target = shadowstepTargets.removeAt(nextTargetIndex);
    if (target.isRemoved){
      shadowstep();
      return;
    }

    widget.gameRef.camera.moveToTargetAnimated(
      effectController: EffectController(
        curve: Curves.easeInOut,
        speed: 700,
      ),
      followTarget: false,
      target: target,
      onComplete: () {
        widget.gameRef.camera.follow(player);
        gameState.isPaused = false;
      },
    );
    player.position = target.position.clone()..add(Vector2(0, -16));

    if (tendrilsTarget != null) setShadowyTendrilsTarget(target.entityType);
  }

  void closeShadowyTendrils() {
    setState(() {
      tendrilsTarget = null;
      selectedActionType = null;
    });

    if (gameState.isPaused) gameState.isPaused = false;
  }

  Future<void> shadowyTendrils() async {
    if (tendrilsTarget != null) {
      closeShadowyTendrils();
      return;
    }

    gameState.isPaused = true;
    final character = await CharacterTapManager.$.waitForTap();
    setShadowyTendrilsTarget(character);
  }

  void setShadowyTendrilsTarget(EntityType entityType) => setState(() {
        final availableActions = gameState.availableActionsFor(entityType);
        final target = ShadowyTendrilsTarget(
          entityType,
          availableDarkWhispers: [],
          availableVisionsOfMadness: [],
        );

        for (final action in availableActions) {
          switch (action) {
            case DarkWhispers():
              target.availableDarkWhispers.add(action);
            case VisionsOfMadness():
              target.availableVisionsOfMadness.add(action);
          }
        }

        tendrilsTarget = target;
      });

  void darkWhispersStart() {
    final ShadowyTendrilsTarget? target = tendrilsTarget;
    if (target == null) return;
    if (target.availableDarkWhispers.isEmpty) return;

    setState(() => selectedActionType = TurnActionType.darkWhispers);
  }

  Future<void> visionsOfMadnessStart() async {
    final ShadowyTendrilsTarget? target = tendrilsTarget;
    if (target == null) return;
    if (target.availableDarkWhispers.isEmpty) return;

    setState(() => selectedActionType = TurnActionType.visionsOfMadness);
  }

  void finishOptionPicking(TurnAction pickedOption) {
    turnActions[tendrilsTarget!.target] = pickedOption;
    closeShadowyTendrils();
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(this.text, {required this.onTap});
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          color: onTap != null ? Colors.blue : Colors.grey,
          height: 50,
          width: 50,
          child: Text(text),
        ),
      );
}

class ShadowyTendrilsWidget extends StatelessWidget {
  const ShadowyTendrilsWidget(this.target);
  final EntityType target;

  @override
  Widget build(BuildContext context) {
    final characterState = gameState.ofCharacter(target);
    final hp = characterTracker.ofType(target).life;
    final isDead = characterTracker.ofType(target).isDead;

    return Background(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SpriteWidget.asset(
          //   path: 'knight_idle.png',
          //   srcSize: Vector2.all(16),
          // ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 24),
              children: [
                TextSpan(text: '$target\n'),
                TextSpan(text: '$hp/100 ${isDead ? '💀' : '❤️'}\n'),
                TextSpan(
                  text: '${characterState.sanityLevel}/${target.initialSanity}',
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: 'Behaviour: ${characterState.behaviour}',
                  style: const TextStyle(fontSize: 24),
                ),
                const TextSpan(text: '\n\n'),
                const TextSpan(text: 'Mental States:'),
                const TextSpan(text: '\n'),
                for (final entry in characterState.mentalStates.entries)
                  TextSpan(text: '${entry.key.name}: ${entry.value.name}\n'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SoulWhisperWidget extends StatelessWidget {
  const SoulWhisperWidget({
    required this.options,
    required this.onPicked,
  });
  final List<DarkWhispers> options;
  final void Function(DarkWhispers) onPicked;

  @override
  Widget build(BuildContext context) => Background(
        width: 500,
        child: Column(
          children: [
            const Text('Soul Whisper'),
            for (int i = 0; i < options.length; i++)
              Text('${i + 1}) ${options[i].text}'),
          ],
        ),
      );
}

class ShadowyVisionsWidget extends StatelessWidget {
  const ShadowyVisionsWidget({
    required this.options,
    required this.onPicked,
  });
  final List<VisionsOfMadness> options;
  final void Function(VisionsOfMadness) onPicked;

  @override
  Widget build(BuildContext context) => Background(
        width: 500,
        child: Column(
          children: [
            const Text('Shadowy Visions'),
            for (int i = 0; i < options.length; i++)
              Text('${i + 1}) ${options[i].text}'),
          ],
        ),
      );
}

class Background extends StatelessWidget {
  const Background({required this.child, this.width});
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 5),
        ),
        padding: const EdgeInsets.all(16),
        width: width,
        child: child,
      );
}
