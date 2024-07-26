import 'dart:async';

import 'package:bonfire/bonfire.dart';

Future<void> _future(Function(Function()) fn) {
  final Completer<void> completer = Completer();
  fn(() => completer.complete());
  return completer.future;
}

extension PathFindingFutures on PathFinding {
  Future<void> pathfindToPosition(Vector2 position) => _future(
        (onFinish) => moveToPositionWithPathFinding(
          position,
          onFinish: onFinish,
        ),
      );
}
