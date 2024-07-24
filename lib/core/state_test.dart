import 'package:test/test.dart';

import 'state_machine.dart';

void main() {
  test('state', () {
    final gameState = GameState();
    gameState.endTurn(const [SoulWhisper(Peasant(), MentalState.manic, 170)]);

    for (int i = 0; i < 10; i++){
      gameState.endTurn();
    }

    // expect(gameState.currentTurn, 11);
  });
}
