import 'package:flutter/material.dart';

import '../state/state.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key});

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
                        ActionButton('1', onTap: () {}),
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
