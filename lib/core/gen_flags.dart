// ignore_for_file: avoid_print

import 'dart:io';

const dir = './lib/core';
const input = 'flags.txt';
const fileName = 'flags';

void main() {
  final file = File('$dir/$input');
  final lines = file.readAsStringSync().split('\n');
  if (lines.last.isEmpty) lines.removeLast();

  final StringBuffer buffer = StringBuffer();
  buffer
    ..writeln('/// AUTO-GENERATED, DO NOT MODIFY BY HAND!')
    ..writeln()
    ..writeln("part of '$fileName.dart';")
    ..writeln();

  bool isFirstLine = true;
  final List<String> entityNames = [];

  for (final line in lines) {
    if (line.isEmpty) {
      isFirstLine = true;
      continue;
    }

    if (isFirstLine) {
      final className =
          _capitalize(line).replaceFirst(':', '').replaceAll(' ', '');
      buffer
        ..writeln('class $className extends EntityType {')
        ..writeln('  const $className();')
        ..writeln('}');
      entityNames.add(className);
    } else {
      final entityName = entityNames.last;
      final className = '${_capitalize(entityName)}${_capitalize(line)}';
      buffer
        ..writeln('class $className extends BehaviourFlag<$entityName> {')
        ..writeln('  const $className();')
        ..writeln('}');
    }

    if (line != lines.last) buffer.writeln();
    isFirstLine = false;
  }

  // print(buffer.toString());

  final output = File('$dir/$fileName.g.dart');
  if (output.existsSync()) output.deleteSync();
  output.writeAsStringSync(buffer.toString());
}

String _capitalize(String str) {
  if (str.length <= 1) return str.toUpperCase();
  return str[0].toUpperCase() + str.substring(1);
}
