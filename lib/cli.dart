// import 'dart:io';

// import 'package:whisper/state/state_machine.dart';
//
// void main() {
//   final gameState = GameState();
//
//   while (true) {
//     print(gameState);
//
//     final int option = selectOption(const ['Soul Whisper', 'Skip Turn']);
//     final List<UserAction> turnActions = [];
//     if (option == 0) turnActions.add(promptSoulWhisper());
//
//     gameState.endTurn(turnActions);
//   }
// }
//
// SoulWhisper promptSoulWhisper() {
//   final target = selectCharacter();
//   final mentalState = selectMentalState();
//   int? bonus;
//
//   print("How much are we increasing $target's ${mentalState.name}?");
//
//   do {
//     bonus = int.tryParse(stdin.readLineSync() ?? '');
//   } while (bonus == null);
//
//   return SoulWhisper(target, mentalState, bonus);
// }
//
// MentalState selectMentalState() {
//   print('Select mental state:');
//   final options = MentalState.values.map((v) => v.name).toList();
//   return MentalState.values[selectOption(options)];
// }
//
// EntityType selectCharacter() {
//   const characters = [Peasant(), VillageAlchemist()];
//   print('Select target character');
//   final options = selectOption(characters.map((c) => c.toString()).toList());
//   return characters[options];
// }
//
// int selectOption(List<String> options) {
//   final StringBuffer buffer = StringBuffer();
//
//   for (int i = 0; i < options.length; i++) {
//     buffer.write('${i + 1}. ${options[i]}');
//     if (i < options.length - 1) buffer.writeln();
//   }
//
//   print(buffer.toString());
//
//   int input = -1;
//   do {
//     input = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
//   } while (input < 0 || input > options.length);
//
//   return input - 1;
// }
