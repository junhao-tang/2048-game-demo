import 'dart:math';

import 'package:demo2048/math.dart';
import 'package:flutter/material.dart';

enum Direction {
  up,
  down,
  left,
  right,
}

Random _rand = Random();

class Node {
  // if one prefers to remove presentation layer data,
  // we can replace this with a unique key
  // this can be used in doing animation too
  late Color colour;
  int value;

  Node(this.value) {
    colour = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }
}

class Game extends ChangeNotifier {
  static const int puzzleSize = 4; // 4x4
  static const int goal = 2048;
  static const int initialValue = 2;

  final Map<int, Node> data = {};
  int _highest = 0;

  void slide(Direction direction) {
    var mapper = List<List<int>>.generate(
      puzzleSize,
      (i) => List<int>.generate(puzzleSize, (j) => i * puzzleSize + j).toList(),
    ).toList();

    switch (direction) {
      case Direction.left:
        break;
      case Direction.up:
        transpose(mapper);
        break;
      case Direction.right:
        reflect(mapper);
        break;
      case Direction.down:
        transpose(mapper);
        reflect(mapper);
        break;
    }

    for (int i = 0; i < mapper.length; i++) {
      var lastEmpty = data[mapper[i][0]] == null ? 0 : 1;
      var lastMerger = 0;
      for (int j = 1; j < mapper.length; j++) {
        var mappedIdx = mapper[i][j];
        if (data[mappedIdx] != null) {
          if (lastMerger < lastEmpty) {
            var mergerIdx = mapper[i][lastMerger];
            var mergingTarget = data[mergerIdx]!;
            if (data[mappedIdx]!.value == mergingTarget.value) {
              var sum = mergingTarget.value + data[mappedIdx]!.value;
              if (sum > _highest) _highest = sum;
              data[mergerIdx]!.value = sum;
              data.remove(mappedIdx);
              lastMerger++;
              continue;
            }
            lastMerger++;
          }
          // shift to last empty position
          if (j != lastEmpty) {
            var emptyIdx = mapper[i][lastEmpty];
            data[emptyIdx] = data[mappedIdx]!;
            data.remove(mappedIdx);
          }
          lastEmpty++;
        }
      }
    }
    notifyListeners();
  }

  int generateRandom(int count) {
    var generating = min(count, emptySpaces);
    var availables =
        List<int>.generate(puzzleSize * puzzleSize, (index) => index)
            .toSet()
            .difference(
              data.keys.toSet(),
            )
            .toList()
          ..shuffle();
    for (int i = 0; i < generating; i++) {
      data[availables[i]] = Node(
        initialValue,
      );
    }
    notifyListeners();
    return generating;
  }

  Node getNode(int i, int j) => data[i * puzzleSize + j]!;
  bool get isWon => _highest >= goal;
  bool get noMoreMove {
    if (emptySpaces > 0) return false;
    for (int i = 0; i < puzzleSize; i++) {
      for (int j = 0; j < puzzleSize; j++) {
        var currentValue = getNode(i, j).value;
        if (i < puzzleSize - 1 && currentValue == getNode(i + 1, j).value) {
          return false;
        }
        if (j < puzzleSize - 1 && currentValue == getNode(i, j + 1).value) {
          return false;
        }
      }
    }
    return true;
  }

  int get emptySpaces => puzzleSize * puzzleSize - data.length;
}
