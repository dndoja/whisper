import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:whisper/core/chase.dart';

Future<void> wrapInFuture(Function(Function()) fn) {
  final Completer<void> completer = Completer();
  fn(() => completer.complete());
  return completer.future;
}

extension ChaseFuture on ChaseMovement {
  Future<void> chase(Npc target) =>
      wrapInFuture((onFinish) => chaseTarget(target, onFinish: onFinish));
}
