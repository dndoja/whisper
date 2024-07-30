// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whisper/core/core.dart';

class ShadowyTendrilsTarget {
  const ShadowyTendrilsTarget(
    this.entityType, {
    required this.availableActions,
  });

  final EntityType entityType;
  final List<TurnAction> availableActions;
}

final GlobalKey<_UIState> _bottomPanelKey = GlobalKey();

const int maxShadowTendrilsPerTurn = 2;

enum GameOverResult {
  alchemistHarmed,
  interruptedExperiment,
  experimentSuccess,
}

class GameOverData {
  const GameOverData({
    required this.result,
    required this.scenariosDiscoveredSession,
    required this.scenariosDiscoveredTotal,
  });
  final GameOverResult result;
  final int scenariosDiscoveredSession;
  final int scenariosDiscoveredTotal;
}

class UI extends StatefulWidget {
  UI(this.gameRef) : super(key: _bottomPanelKey);
  final BonfireGame gameRef;

  @override
  State<UI> createState() => _UIState();

  static void setTendrilsTarget(EntityType? target) {
    _bottomPanelKey.currentState?.setShadowyTendrilsTarget(target);
  }

  static void startTurnTransition() =>
      _bottomPanelKey.currentState?.startTurnTransition();
  static void endTurnTransition() =>
      _bottomPanelKey.currentState?.endTurnTransition();
  static void endTurn() => _bottomPanelKey.currentState?.endTurn();
  static void finishGame(GameOverResult result) =>
      _bottomPanelKey.currentState?.finishGame(result);
}

class _UIState extends State<UI> {
  final List<GameCharacter> shadowstepTargets = [];
  Map<EntityType, TurnAction> stagedTurnActions = {};
  Map<EntityType, List<TurnAction>> availableTurnActions = {};

  ShadowyTendrilsTarget? tendrilsTarget;
  TurnActionType? selectedActionType;

  bool isTransitioningTurns = false;
  GameOverData? gameOver;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyPressed);
    availableTurnActions = gameState.availableTurnActions();
    endTurn();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyPressed);
    super.dispose();
  }

  void startTurnTransition() => setState(() => isTransitioningTurns = true);
  void endTurnTransition() => setState(() => isTransitioningTurns = false);

  @override
  Widget build(BuildContext context) {
    final target = tendrilsTarget;
    final bool canCastTendrils = target != null &&
        !stagedTurnActions.containsKey(target.entityType) &&
        target.availableActions.isNotEmpty &&
        stagedTurnActions.length < maxShadowTendrilsPerTurn;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: gameOver != null
            ? [
                Align(
                  alignment: Alignment.center,
                  child: GameOver(gameOver!),
                )
              ]
            : [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Turn: ${gameState.currentTurn}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      shadows: [BoxShadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                ),
                if (!isTransitioningTurns) ...[
                  if (tendrilsTarget != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ShadowyTendrilsWidget(tendrilsTarget!.entityType),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: ActionCards(
                      onSelected: (entityType, action) {
                        characterTracker.ofType(entityType).showShadowCard();
                        setState(() => stagedTurnActions[entityType] = action);
                        if (stagedTurnActions.length >=
                            maxShadowTendrilsPerTurn) endTurn();
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 220,
                    child: ActionButton(
                      name: 'Shadow\nStep',
                      keybind: 'Q',
                      onTap: ActionCards.areOpen ? null : shadowstep,
                      charges: '∞',
                      tooltip:
                          "Instantly teleports to a vulnerable Mortal's location.",
                    ),
                  ),
                  Positioned(
                    bottom: 180,
                    right: 180,
                    child: ActionButton(
                      charges:
                          '${maxShadowTendrilsPerTurn - stagedTurnActions.length}/'
                          '$maxShadowTendrilsPerTurn',
                      name: 'Shadowy\nTendrils',
                      keybind: ' ',
                      onTap: canCastTendrils ? toggleCards : null,
                      tooltip: 'Invade the soul of a vulnerable mortal,\n'
                          'allowing you to mess with their head',
                    ),
                  ),
                ],
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: InkWell(
                    onTap: endTurn,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isTransitioningTurns ? Colors.grey : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      height: 170,
                      width: 170,
                      child: isTransitioningTurns
                          ? const CircularProgressIndicator()
                          : const Text(
                              'End Turn (F)',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  void endTurn() {
    if (isTransitioningTurns) return;

    setState(() {
      gameState.endTurn(stagedTurnActions);
      stagedTurnActions = {};
      availableTurnActions = gameState.availableTurnActions();
    });

    if (tendrilsTarget != null) {
      setShadowyTendrilsTarget(tendrilsTarget?.entityType, forceRefresh: true);
    }
  }

  bool _onKeyPressed(KeyEvent event) {
    if (gameOver != null || isTransitioningTurns || event is! KeyUpEvent) {
      return false;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyQ:
        shadowstep();
        return true;
      case LogicalKeyboardKey.space:
        toggleCards();
        return true;
      case LogicalKeyboardKey.keyF:
        endTurn();
        return true;
      case LogicalKeyboardKey.keyR:
        characterTracker.allAlive
            .firstOrNullWhere((c) => c.entityType == tendrilsTarget?.entityType)
            ?.die();
      default:
    }

    if (ActionCards.areOpen) {
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

      return ActionCards.selectCard(index);
    }

    return false;
  }

  void shadowstep() {
    if (ActionCards.areOpen || isTransitioningTurns) return;

    gameState.isPaused = true;

    if (shadowstepTargets.isEmpty) {
      final Iterable<GameCharacter> targets = characterTracker.allAlive
          .where((c) => availableTurnActions[c.entityType]?.isNotEmpty == true);
      if (targets.isEmpty) return;
      shadowstepTargets.addAll(targets);
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
    if (target.isRemoved) {
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

  void setShadowyTendrilsTarget(
    EntityType? entityType, {
    bool forceRefresh = false,
  }) {
    if (!forceRefresh &&
        (isTransitioningTurns || entityType == tendrilsTarget?.entityType)) {
      return;
    }
    if (entityType == null) {
      if (!ActionCards.areOpen) setState(() => tendrilsTarget = null);
      return;
    }

    setState(() {
      final List<TurnAction> availableActions =
          availableTurnActions[entityType] ?? [];
      final List<DarkWhispers> availableDarkWhispers = [];
      final List<VisionsOfMadness> availableVisionsOfMadness = [];
      for (final action in availableActions) {
        switch (action) {
          case DarkWhispers():
            availableDarkWhispers.add(action);
          case VisionsOfMadness():
            availableVisionsOfMadness.add(action);
        }
      }

      tendrilsTarget = ShadowyTendrilsTarget(
        entityType,
        availableActions: availableVisionsOfMadness.isNotEmpty
            ? availableVisionsOfMadness
            : availableDarkWhispers,
      );
    });
  }

  void toggleCards() {
    if (ActionCards.areOpen) {
      setState(() => ActionCards.close());
      return;
    }

    final target = tendrilsTarget;
    if (target == null ||
        stagedTurnActions.containsKey(target.entityType) ||
        target.availableActions.isEmpty ||
        stagedTurnActions.length >= maxShadowTendrilsPerTurn) return;

    setState(() => ActionCards.openForTarget(target));
  }

  Future<void> finishGame(GameOverResult result) async {
    gameState.isPaused = true;

    final prefs = await SharedPreferences.getInstance();
    const key = 'whisper_visited_outcomes';
    final Iterable<String> prevVisitedOutcomes =
        prefs.getStringList(key) ?? const [];
    final Iterable<String> currVisitedOutcomes =
        gameState.visitedFinalBehaviours.map((b) => b.toString());
    final Set<String> mergedVisitedOutcomes = {...prevVisitedOutcomes};
    final List<String> newVisitedOutcomes = [];

    for (final outcome in currVisitedOutcomes) {
      final bool added = mergedVisitedOutcomes.add(outcome);
      if (added) newVisitedOutcomes.add(outcome);
    }

    await prefs.setStringList(key, mergedVisitedOutcomes.toList());

    setState(
      () => gameOver = GameOverData(
        result: result,
        scenariosDiscoveredTotal: mergedVisitedOutcomes.length,
        scenariosDiscoveredSession: newVisitedOutcomes.length,
      ),
    );
  }
}

final GlobalKey<_ActionCardsState> _actionCardsKey = GlobalKey();

class ActionCards extends StatefulWidget {
  ActionCards({
    required this.onSelected,
  }) : super(key: _actionCardsKey);

  final Function(EntityType, TurnAction) onSelected;

  @override
  State<ActionCards> createState() => _ActionCardsState();

  static void openForTarget(ShadowyTendrilsTarget target) =>
      _actionCardsKey.currentState!
          .updateActions(target.entityType, target.availableActions);

  static bool selectCard(int index) =>
      _actionCardsKey.currentState!.selectCard(index);

  static bool areOpen = false;

  static void close() => _actionCardsKey.currentState?.close();
}

class _ActionCardsState extends State<ActionCards>
    with TickerProviderStateMixin {
  late final AnimationController _tappedController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final Animation<double> animTappedScale = Tween<double>(
    begin: 1,
    end: 1.1,
  ).animate(
    CurvedAnimation(
      parent: _tappedController,
      curve: const Interval(
        0,
        0.250,
        curve: Curves.easeOut,
      ),
    ),
  );

  late final Animation<Offset> animOffset = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -2.0),
  ).animate(
    CurvedAnimation(
      parent: _tappedController,
      curve: const Interval(
        0.8,
        1,
        curve: Curves.easeInOut,
      ),
    ),
  );

  late final Animation<double> animTappedOpacity = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _tappedController,
      curve: const Interval(
        0.9,
        1,
        curve: Curves.fastOutSlowIn,
      ),
    ),
  );
  late final Animation<double> animOthersOpacity = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _tappedController,
      curve: const Interval(0, 0.25, curve: Curves.easeInOut),
    ),
  );
  late final Animation<double> animOthersScale = Tween<double>(
    begin: 1,
    end: 0.9,
  ).animate(
    CurvedAnimation(
      parent: _tappedController,
      curve: const Interval(0, 0.25, curve: Curves.easeInOut),
    ),
  );

  EntityType? target;
  int tapped = -1;
  List<TurnAction> actions = [];

  @override
  void initState() {
    super.initState();
    _tappedController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSelected(target!, actions[tapped]);
        tapped = -1;
        target = null;
        setState(() => actions = []);
        ActionCards.areOpen = false;
      }
    });
  }

  void close() => setState(() {
        tapped = -1;
        target = null;
        actions = [];
        ActionCards.areOpen = false;
      });

  void updateActions(
    EntityType target,
    Iterable<TurnAction> actions,
  ) =>
      setState(() {
        _tappedController.reset();
        this.target = target;
        this.actions = List.from(actions);
        tapped = -1;
        ActionCards.areOpen = true;
        // _tappedController.stop();
      });

  bool selectCard(int index) {
    if (index < 0 || index >= actions.length) return false;

    tapped = index;
    _tappedController.forward();
    return true;
  }

  @override
  void dispose() {
    _tappedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: actions.isNotEmpty ? 1 : 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              AnimatedBuilder(
                animation: _tappedController,
                builder: (_, __) => FadeTransition(
                  opacity: tapped == i ? animTappedOpacity : animOthersOpacity,
                  child: ScaleTransition(
                    scale: tapped == i ? animTappedScale : animOthersScale,
                    child: SlideTransition(
                      position: animOffset,
                      child: ShadowCard(
                        title: actions[i].name,
                        text: switch (actions[i]) {
                          VisionsOfMadness(:final text) => text,
                          DarkWhispers(:final text) => text,
                        },
                        onTap: () {
                          tapped = i;
                          _tappedController.forward();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (i < actions.lastIndex) const SizedBox(width: 64),
            ],
          ],
        ),
      );
}

class ShadowCard extends StatefulWidget {
  const ShadowCard({
    required this.text,
    required this.title,
    required this.onTap,
  });
  final void Function() onTap;
  final String title;
  final String text;

  @override
  State<ShadowCard> createState() => _ShadowCardState();
}

class _ShadowCardState extends State<ShadowCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isHovering ? 1.1 : 1,
            child: Stack(
              children: [
                Container(
                  height: 500,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple,
                        blurRadius: 16,
                      ),
                    ],
                    color: Colors.black,
                  ),
                  child: Image.asset(
                    'images/shadow-card.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                ),
                Positioned(
                  left: 48,
                  right: 40,
                  bottom: 40,
                  child: SizedBox(
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.name,
    required this.keybind,
    required this.onTap,
    required this.charges,
    required this.tooltip,
  });
  final String name;
  final String keybind;
  final String charges;
  final void Function()? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  color: onTap != null ? Colors.deepPurpleAccent : Colors.grey,
                  boxShadow: onTap != null
                      ? const [
                          BoxShadow(
                            color: Colors.deepPurple,
                            blurRadius: 8,
                          )
                        ]
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                alignment: Alignment.center,
                height: 90,
                width: 90,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: keybind == ' '
                    ? const Icon(Icons.space_bar)
                    : Text(
                        keybind,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Positioned(
                bottom: 2,
                child: Text(charges),
              ),
            ],
          ),
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
    final pos =
        Point16.fromMapPos(characterTracker.ofType(target).absoluteCenter);

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
                TextSpan(text: target.name),
                const TextSpan(text: '\n'),
                TextSpan(text: '${pos.x}:${pos.y}'),
                const TextSpan(text: '\n'),
                TextSpan(text: '$hp/100 ${isDead ? '💀' : '❤️'}'),
                const TextSpan(text: '\n'),
                TextSpan(
                  text:
                      'Sanity Level: ${characterState.sanityLevel}/${target.initialSanity}',
                ),
                const TextSpan(text: '\n'),
                TextSpan(text: target.description),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: 'Behaviour: ${characterState.behaviour}',
                  style: const TextStyle(fontSize: 24),
                ),
                const TextSpan(text: '\n\n'),
                if (characterState.mentalStates.isNotEmpty) ...[
                  const TextSpan(text: 'Mental States:'),
                  const TextSpan(text: '\n'),
                  for (final entry in characterState.mentalStates.entries)
                    TextSpan(
                      text: '${entry.value.name.capitalize()} '
                          '${entry.key.name.capitalize()}\n',
                    ),
                ],
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

class GameOver extends StatelessWidget {
  const GameOver(this.data);
  final GameOverData data;

  @override
  Widget build(BuildContext context) => Container(
        width: 600,
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 16)],
        ),
        padding: const EdgeInsets.all(64),
        child: Column(
          children: [
            if (data.result == GameOverResult.experimentSuccess)
              const Text(
                'You failed',
                style: TextStyle(fontSize: 70, color: Colors.red),
              )
            else
              const Text(
                'Success',
                style: TextStyle(fontSize: 70, color: Colors.greenAccent),
              ),
            Text(
              switch (data.result) {
                GameOverResult.alchemistHarmed =>
                  'The Alchemist suffered a terrible fate... '
                      'A necessary sacrifice to ensure that the balance of the universe remains maintained.',
                GameOverResult.interruptedExperiment =>
                  "The Alchemist's efforts have been thwarted. We must remain on our guard for he may try again. ",
                GameOverResult.experimentSuccess =>
                  'The God of Death has been outsmarted.'
                      ' The entire Universe is now in disarray, good job!',
              },
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'This game you experienced ${data.scenariosDiscoveredSession}'
              ' out of ${possibleFinalOutcomes.length} total possible outcomes.\n'
              'Throughout all of your playthroughs, you have discovered '
              '${data.scenariosDiscoveredTotal}/${possibleFinalOutcomes.length} total possible outcomes.',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 132),
            ElevatedButton(
              onPressed: html.window.location.reload,
              child: const Text('Back to main menu'),
            ),
          ],
        ),
      );
}
