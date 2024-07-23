import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import '../state/state.dart';

class BottomPanel extends StatefulWidget {
  const BottomPanel(this.gameRef, {super.key});
  final BonfireGame gameRef;

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  final List<SimpleEnemy> shadowStepTargets = [];

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
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
                        ActionButton('2', onTap: () {}),
                        const SizedBox(width: 32),
                        ActionButton('3', onTap: () {}),
                        const SizedBox(width: 32),
                        ActionButton('4', onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => GameState.$.endTurn([
                      const SoulWhisper(CrazyJoe(), MentalState.paranoid, 150),
                    ]),
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
            ),
          ],
        ),
      );

  void shadowStep() {
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
      if (distance > distanceToTarget) {
        nextTargetIndex = i;
        distanceToTarget = distance;
      }
    }

    final SimpleEnemy target = shadowStepTargets.removeAt(nextTargetIndex);
    widget.gameRef.camera.moveToTargetAnimated(
      target: target,
      onComplete: () {
        player.position = target.position.clone()..add(Vector2(0, -16));
        widget.gameRef.camera.moveToPlayerAnimated(
          onComplete: () => widget.gameRef.camera.follow(player),
        );
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(this.text, {required this.onTap});
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          color: Colors.blue,
          height: 50,
          width: 50,
          child: Text(text),
        ),
      );
}
