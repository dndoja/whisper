import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whisper/core/core.dart';

const loremIpsum =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vitae leo ac nisl sodales molestie sit amet eu nunc. Ut in mi vel tortor auctor tempus a sit amet erat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ac nisl a ex malesuada ornare sed et velit. In nec nisi eget est eleifend aliquet. Etiam vel porttitor neque, sed dignissim risus. Duis enim erat, efficitur sed augue vel, ornare rhoncus libero.';

class SoulMirrorTarget {
  const SoulMirrorTarget(
    this.target, {
    required this.availableShadowyVisions,
    required this.availableSoulWhispers,
  });

  final EntityType target;
  final List<ShadowyVisions> availableShadowyVisions;
  final List<SoulWhisper> availableSoulWhispers;
}

class BottomPanel extends StatefulWidget {
  const BottomPanel(this.gameRef, {super.key});
  final BonfireGame gameRef;

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  final List<SimpleEnemy> shadowStepTargets = [];
  Map<EntityType, TurnAction> turnActions = {};

  SoulMirrorTarget? soulMirrorTarget;
  TurnActionType? selectedActionType;

  bool get canSoulWhisper =>
      soulMirrorTarget?.availableSoulWhispers.isNotEmpty == true;

  bool get canShadowyVisions =>
      soulMirrorTarget?.availableShadowyVisions.isNotEmpty == true;

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
            if (soulMirrorTarget != null)
              Align(
                alignment: Alignment.centerLeft,
                child: SoulMirrorWidget(soulMirrorTarget!.target),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedActionType == TurnActionType.soulWhisper)
                    SoulWhisperWidget(
                      options: soulMirrorTarget!.availableSoulWhispers,
                      onPicked: finishOptionPicking,
                    )
                  else if (selectedActionType == TurnActionType.shadowyVisions)
                    ShadowyVisionsWidget(
                      options: soulMirrorTarget!.availableShadowyVisions,
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
                            ActionButton('1', onTap: shadowStep),
                            const SizedBox(width: 32),
                            ActionButton('2', onTap: soulMirror),
                            const SizedBox(width: 32),
                            ActionButton(
                              '3',
                              onTap: canSoulWhisper ? soulWhisperStart : null,
                            ),
                            const SizedBox(width: 32),
                            ActionButton(
                              '4',
                              onTap: canShadowyVisions ? shadowyVisions : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          GameState.$.endTurn(turnActions);
                          turnActions = {};
                        },
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

  bool _onKeyPressed(KeyEvent event) {
    if (event is! KeyUpEvent) return false;

    final List<TurnAction> currentActions = switch (selectedActionType) {
      TurnActionType.soulWhisper =>
        soulMirrorTarget?.availableSoulWhispers ?? const [],
      TurnActionType.shadowyVisions =>
        soulMirrorTarget?.availableShadowyVisions ?? const [],
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
        shadowStep();
      case LogicalKeyboardKey.digit2:
        soulMirror();
      case LogicalKeyboardKey.digit3:
        soulWhisperStart();
      case LogicalKeyboardKey.digit4:
        shadowyVisions();
      default:
        return false;
    }

    return true;
  }

  void shadowStep() {
    if (GameState.$.isPaused) return;

    GameState.$.isPaused = true;

    if (shadowStepTargets.isEmpty) {
      final Iterable<SimpleEnemy> enemies = widget.gameRef.query();
      if (enemies.isEmpty) return;
      shadowStepTargets.addAll(enemies);
    }

    final player = widget.gameRef.player!;
    int nextTargetIndex = 0;
    double distanceToTarget = -1;

    for (int i = 0; i < shadowStepTargets.length; i++) {
      final SimpleEnemy target = shadowStepTargets[i];
      final double distance = target.distance(player);
      if (distance < distanceToTarget) {
        nextTargetIndex = i;
        distanceToTarget = distance;
      }
    }

    final SimpleEnemy target = shadowStepTargets.removeAt(nextTargetIndex);
    widget.gameRef.camera.moveToTargetAnimated(
      effectController: EffectController(
        curve: Curves.easeInOut,
        speed: 700,
      ),
      followTarget: false,
      target: target,
      onComplete: () {
        widget.gameRef.camera.follow(player);
        GameState.$.isPaused = false;
      },
    );
    player.position = target.position.clone()..add(Vector2(0, -16));
  }

  void closeSoulMirror() {
    setState(() {
      soulMirrorTarget = null;
      selectedActionType = null;
    });

    if (GameState.$.isPaused) GameState.$.isPaused = false;
  }

  Future<void> soulMirror() async {
    print('Opening soul mirror ${GameState.$.isPaused}');
    if (soulMirrorTarget != null) {
      closeSoulMirror();
      return;
    }

    GameState.$.isPaused = true;
    final character = await CharacterTapManager.$.waitForTap();

    setState(() {
      final availableActions = GameState.$.availableActionsFor(character);
      final target = SoulMirrorTarget(
        character,
        availableSoulWhispers: [],
        availableShadowyVisions: [],
      );

      for (final action in availableActions) {
        switch (action) {
          case SoulWhisper():
            target.availableSoulWhispers.add(action);
          case ShadowyVisions():
            target.availableShadowyVisions.add(action);
        }
      }

      soulMirrorTarget = target;
    });
  }

  void soulWhisperStart() {
    final SoulMirrorTarget? target = soulMirrorTarget;
    if (target == null) return;
    if (target.availableSoulWhispers.isEmpty) return;

    setState(() => selectedActionType = TurnActionType.soulWhisper);
  }

  void finishOptionPicking(TurnAction pickedOption) {
    turnActions[soulMirrorTarget!.target] = pickedOption;
    closeSoulMirror();
  }

  Future<void> shadowyVisions() async {
    final SoulMirrorTarget? target = soulMirrorTarget;
    if (target == null) return;
    final actions = target.availableShadowyVisions;
    if (actions.isEmpty) return;
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

class SoulMirrorWidget extends StatelessWidget {
  const SoulMirrorWidget(this.target);
  final EntityType target;

  @override
  Widget build(BuildContext context) => Background(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SpriteWidget.asset(
            //   path: 'knight_idle.png',
            //   srcSize: Vector2.all(16),
            // ),
            const SizedBox(height: 16),
            Text(
              '${GameState.$.ofCharacter(target).sanityLevel}/${target.initialSanity}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            const Text(loremIpsum)
          ],
        ),
      );
}

class SoulWhisperWidget extends StatelessWidget {
  const SoulWhisperWidget({
    required this.options,
    required this.onPicked,
  });
  final List<SoulWhisper> options;
  final void Function(SoulWhisper) onPicked;

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
  final List<ShadowyVisions> options;
  final void Function(ShadowyVisions) onPicked;

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
          color: Colors.black45,
          border: Border.all(color: Colors.red, width: 5),
        ),
        padding: const EdgeInsets.all(16),
        width: width,
        child: child,
      );
}
