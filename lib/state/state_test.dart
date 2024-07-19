import 'package:test/test.dart';

import 'state.dart';

void main() {
  test('state', () {
    final gameState = GameState();
    for (int i = 0; i < 10; i++) {
      gameState.nextTurn();
    }
    
    expect(gameState.currentTurn, 11);
  });
}
